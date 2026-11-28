using System.Globalization;
using System.Text;
using Microsoft.EntityFrameworkCore;
using TecNM.Api.Data;

namespace TecNM.Api.Features.Books;

public interface IBookService
{
    Task<IReadOnlyList<BookDto>> GetBooksAsync(string? search, string? field, string? status, string? sortBy);
    Task<BookDto?> GetBookByIdAsync(int id);
    Task<BookMetricsDto> GetMetricsAsync();
    Task<NextFolioDto> GetNextAvailableFolioAsync();
    Task<(BookDto? Book, string? Error, bool IsConflict)> CreateBookAsync(CreateBookRequest req);
    Task<(BookDto? Book, string? Error, bool IsNotFound, bool IsConflict)> UpdateBookAsync(int id, UpdateBookRequest req);
    Task<bool> UpdateStatusAsync(int id, UpdateBookStatusRequest req);
    Task<bool> SoftDeleteAsync(int id);
    Task<IReadOnlyList<ShelfDto>> GetShelvesAsync();
    Task<(ShelfDto? Shelf, string? Error)> CreateShelfAsync(CreateShelfRequest req);
    Task<IReadOnlyList<TopicDto>> GetTopicsAsync();
    Task<(TopicDto? Topic, string? Error)> CreateTopicAsync(CreateTopicRequest req);
    Task<IReadOnlyList<BookStatusDto>> GetStatusesAsync();
}

public sealed class BookService(TecNMDbContext db) : IBookService
{
    private const int MinimumStartingFolio = 5000;

    /// <summary>
    /// Normaliza texto removiendo acentos/diacríticos y convirtiendo a minúsculas
    /// para búsquedas insensibles a acentos, mayúsculas y minúsculas.
    /// </summary>
    public static string NormalizeSearchText(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return string.Empty;
        }

        var decomposed = value.Trim().Normalize(NormalizationForm.FormD);
        var sb = new StringBuilder(decomposed.Length);
        foreach (var ch in decomposed)
        {
            if (CharUnicodeInfo.GetUnicodeCategory(ch) != UnicodeCategory.NonSpacingMark)
            {
                sb.Append(char.ToLowerInvariant(ch));
            }
        }

        return sb.ToString().Normalize(NormalizationForm.FormC);
    }

    public static string NormalizeFolio(string? rawFolio)
    {
        if (string.IsNullOrWhiteSpace(rawFolio))
        {
            return string.Empty;
        }

        return rawFolio.Trim().TrimStart('#').Trim();
    }

    public async Task<NextFolioDto> GetNextAvailableFolioAsync()
    {
        var existingFolios = await db.Books
            .IgnoreQueryFilters()
            .Select(b => b.Folio)
            .ToListAsync();

        var usedNumbers = new HashSet<int>();
        foreach (var raw in existingFolios)
        {
            var cleaned = NormalizeFolio(raw);
            if (int.TryParse(cleaned, NumberStyles.Integer, CultureInfo.InvariantCulture, out var num)
                && num >= MinimumStartingFolio)
            {
                usedNumbers.Add(num);
            }
        }

        var candidate = MinimumStartingFolio;
        while (usedNumbers.Contains(candidate))
        {
            candidate++;
        }

        var folioStr = candidate.ToString(CultureInfo.InvariantCulture);
        return new NextFolioDto(folioStr, candidate);
    }

    public async Task<IReadOnlyList<BookDto>> GetBooksAsync(
        string? search,
        string? field,
        string? status,
        string? sortBy)
    {
        var query = db.Books
            .Include(b => b.Status)
            .Include(b => b.Shelf)
            .Include(b => b.BookTopics)
                .ThenInclude(bt => bt.Topic)
            .AsNoTracking();

        if (!string.IsNullOrWhiteSpace(status) && !status.Equals("all", StringComparison.OrdinalIgnoreCase))
        {
            query = status.ToLowerInvariant() switch
            {
                "disponible" => query.Where(b => b.StatusId == 1),
                "prestado" => query.Where(b => b.StatusId == 2),
                "reparacion" => query.Where(b => b.StatusId == 3),
                "baja" => query.Where(b => b.StatusId == 4),
                "catalogo" => query.Where(b => b.StatusId == 5),
                _ => query
            };
        }

        var books = await query.ToListAsync();

        // Filtro en memoria insensible a acentos, mayúsculas y minúsculas (Cero SQL crudo)
        if (!string.IsNullOrWhiteSpace(search))
        {
            var normalizedSearch = NormalizeSearchText(search);
            var normalizedFolioTerm = NormalizeSearchText(NormalizeFolio(search));
            var tokens = normalizedSearch.Split(' ', StringSplitOptions.RemoveEmptyEntries);
            var targetField = (field ?? "all").Trim().ToLowerInvariant();

            books = books.Where(b =>
            {
                var normTitle = NormalizeSearchText(b.Title);
                var normAuthor = NormalizeSearchText(b.Author);
                var normNote = NormalizeSearchText(b.Note);
                var normDewey = NormalizeSearchText(b.Dewey);
                var normCutter = NormalizeSearchText(b.Cutter);
                var normFolio = NormalizeSearchText(NormalizeFolio(b.Folio));
                var normShelf = NormalizeSearchText(b.Shelf?.Name);
                var normTopics = string.Join(' ', b.BookTopics
                    .Where(bt => bt.Topic != null)
                    .Select(bt => NormalizeSearchText(bt.Topic!.Name)));

                return targetField switch
                {
                    "title" => tokens.All(t => normTitle.Contains(t, StringComparison.Ordinal)),
                    "dewey" => normDewey.Contains(normalizedSearch, StringComparison.Ordinal),
                    "folio" or "barcode" => !string.IsNullOrEmpty(normalizedFolioTerm)
                        && normFolio.Contains(normalizedFolioTerm, StringComparison.Ordinal),
                    "author" => tokens.All(t => normAuthor.Contains(t, StringComparison.Ordinal)),
                    _ => tokens.All(t =>
                        normTitle.Contains(t, StringComparison.Ordinal)
                        || normDewey.Contains(t, StringComparison.Ordinal)
                        || normFolio.Contains(t.TrimStart('#'), StringComparison.Ordinal)
                        || normAuthor.Contains(t, StringComparison.Ordinal)
                        || normNote.Contains(t, StringComparison.Ordinal)
                        || normCutter.Contains(t, StringComparison.Ordinal)
                        || normShelf.Contains(t, StringComparison.Ordinal)
                        || normTopics.Contains(t, StringComparison.Ordinal))
                };
            }).ToList();
        }

        books = (sortBy?.ToLowerInvariant()) switch
        {
            "status" => books.OrderBy(b => b.StatusId).ThenBy(b => b.Title).ToList(),
            "barcode" or "folio" => books.OrderBy(b =>
                int.TryParse(NormalizeFolio(b.Folio), out var n) ? n : int.MaxValue)
                .ThenBy(b => b.Folio)
                .ToList(),
            "relevance" => books.OrderBy(b => b.Title).ToList(),
            _ => books.OrderBy(b => b.Dewey).ThenBy(b => b.Title).ToList()
        };

        return books.Select(MapToDto).ToList();
    }

    public async Task<BookDto?> GetBookByIdAsync(int id)
    {
        var book = await db.Books
            .Include(b => b.Status)
            .Include(b => b.Shelf)
            .Include(b => b.BookTopics)
                .ThenInclude(bt => bt.Topic)
            .AsNoTracking()
            .FirstOrDefaultAsync(b => b.Id == id);

        return book is null ? null : MapToDto(book);
    }

    public async Task<BookMetricsDto> GetMetricsAsync()
    {
        var books = await db.Books.AsNoTracking().ToListAsync();

        return new BookMetricsDto(
            TotalBooks: books.Count,
            AvailableCount: books.Count(b => b.StatusId == 1),
            BorrowedCount: books.Count(b => b.StatusId == 2),
            RepairCount: books.Count(b => b.StatusId == 3),
            DiscardCount: books.Count(b => b.StatusId == 4),
            CatalogCount: books.Count(b => b.StatusId == 5)
        );
    }

    public async Task<(BookDto? Book, string? Error, bool IsConflict)> CreateBookAsync(CreateBookRequest req)
    {
        if (string.IsNullOrWhiteSpace(req.Title))
        {
            return (null, "El título de la obra es obligatorio.", false);
        }

        var requestedFolio = NormalizeFolio(req.Folio);
        string assignedFolio;

        if (string.IsNullOrWhiteSpace(requestedFolio))
        {
            var next = await GetNextAvailableFolioAsync();
            assignedFolio = next.NextFolio;
        }
        else
        {
            if (int.TryParse(requestedFolio, NumberStyles.Integer, CultureInfo.InvariantCulture, out var parsedFolio)
                && parsedFolio < MinimumStartingFolio)
            {
                var next = await GetNextAvailableFolioAsync();
                return (null, $"Los folios deben asignarse a partir del número {MinimumStartingFolio} en adelante. Siguiente folio disponible: {next.NextFolio}.", false);
            }

            // Verificar si el folio ya existe antes de asignarlo (evitar folios repetidos)
            var folioExists = await db.Books
                .IgnoreQueryFilters()
                .AnyAsync(b => b.Folio == requestedFolio || b.Folio == "#" + requestedFolio);

            if (folioExists)
            {
                var next = await GetNextAvailableFolioAsync();
                return (null, $"El folio '{requestedFolio}' ya existe en el sistema. Siguiente folio consecutivo disponible: {next.NextFolio}.", true);
            }

            assignedFolio = requestedFolio;
        }

        var shelfId = req.ShelfId > 0 ? req.ShelfId : 1;
        if (!string.IsNullOrWhiteSpace(req.ShelfName))
        {
            var resolvedShelf = await ResolveOrCreateShelfAsync(req.ShelfName);
            shelfId = resolvedShelf.Id;
        }

        var book = new Book
        {
            Title = req.Title.Trim(),
            Author = req.Author?.Trim(),
            Note = req.Note?.Trim(),
            Folio = assignedFolio,
            Dewey = string.IsNullOrWhiteSpace(req.Dewey) ? "000" : req.Dewey.Trim(),
            Cutter = string.IsNullOrWhiteSpace(req.Cutter) ? ".A00" : req.Cutter.Trim(),
            StatusId = req.StatusId is >= 1 and <= 5 ? req.StatusId : 1,
            ShelfId = shelfId,
            DateCreate = DateTime.UtcNow,
            IdStatus = true
        };

        db.Books.Add(book);
        await db.SaveChangesAsync();

        if (req.Topics is { Count: > 0 })
        {
            await SyncBookTopicsAsync(book.Id, req.Topics);
        }

        var created = await GetBookByIdAsync(book.Id);
        return (created, null, false);
    }

    public async Task<(BookDto? Book, string? Error, bool IsNotFound, bool IsConflict)> UpdateBookAsync(int id, UpdateBookRequest req)
    {
        var book = await db.Books.FindAsync(id);
        if (book is null)
        {
            return (null, "Ejemplar no encontrado.", true, false);
        }

        if (string.IsNullOrWhiteSpace(req.Title))
        {
            return (null, "El título de la obra es obligatorio.", false, false);
        }

        if (!string.IsNullOrWhiteSpace(req.Folio))
        {
            var cleanedFolio = NormalizeFolio(req.Folio);
            var duplicate = await db.Books
                .IgnoreQueryFilters()
                .AnyAsync(b => b.Id != id && (b.Folio == cleanedFolio || b.Folio == "#" + cleanedFolio));

            if (duplicate)
            {
                return (null, $"El folio '{cleanedFolio}' ya está asignado a otro ejemplar.", false, true);
            }

            book.Folio = cleanedFolio;
        }

        book.Title = req.Title.Trim();
        book.Author = req.Author?.Trim();
        book.Note = req.Note?.Trim();
        book.Dewey = string.IsNullOrWhiteSpace(req.Dewey) ? book.Dewey : req.Dewey.Trim();
        book.Cutter = string.IsNullOrWhiteSpace(req.Cutter) ? book.Cutter : req.Cutter.Trim();
        if (req.StatusId is >= 1 and <= 5)
        {
            book.StatusId = req.StatusId;
        }

        if (!string.IsNullOrWhiteSpace(req.ShelfName))
        {
            var shelf = await ResolveOrCreateShelfAsync(req.ShelfName);
            book.ShelfId = shelf.Id;
        }

        book.DateUpdate = DateTime.UtcNow;
        await db.SaveChangesAsync();

        if (req.Topics is not null)
        {
            await SyncBookTopicsAsync(book.Id, req.Topics);
        }

        var updated = await GetBookByIdAsync(book.Id);
        return (updated, null, false, false);
    }

    public async Task<bool> UpdateStatusAsync(int id, UpdateBookStatusRequest req)
    {
        var book = await db.Books.FindAsync(id);
        if (book is null)
        {
            return false;
        }

        book.StatusId = req.StatusId;
        if (!string.IsNullOrWhiteSpace(req.Note))
        {
            book.Note = req.Note.Trim();
        }
        book.DateUpdate = DateTime.UtcNow;

        await db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> SoftDeleteAsync(int id)
    {
        var book = await db.Books.FindAsync(id);
        if (book is null)
        {
            return false;
        }

        book.IdStatus = false;
        book.DateDelete = DateTime.UtcNow;

        await db.SaveChangesAsync();
        return true;
    }

    public async Task<IReadOnlyList<ShelfDto>> GetShelvesAsync()
    {
        return await db.Shelves
            .AsNoTracking()
            .OrderBy(s => s.Id)
            .Select(s => new ShelfDto(s.Id, s.Name))
            .ToListAsync();
    }

    public async Task<(ShelfDto? Shelf, string? Error)> CreateShelfAsync(CreateShelfRequest req)
    {
        if (string.IsNullOrWhiteSpace(req.Name))
        {
            return (null, "El código o nombre del estante es obligatorio.");
        }

        var shelf = await ResolveOrCreateShelfAsync(req.Name);
        return (new ShelfDto(shelf.Id, shelf.Name), null);
    }

    public async Task<IReadOnlyList<TopicDto>> GetTopicsAsync()
    {
        return await db.Topics
            .AsNoTracking()
            .OrderBy(t => t.Name)
            .Select(t => new TopicDto(t.Id, t.Name))
            .ToListAsync();
    }

    public async Task<(TopicDto? Topic, string? Error)> CreateTopicAsync(CreateTopicRequest req)
    {
        if (string.IsNullOrWhiteSpace(req.Name))
        {
            return (null, "El nombre del tema es obligatorio.");
        }

        var normalized = NormalizeSearchText(req.Name);
        var existingTopics = await db.Topics.ToListAsync();
        var match = existingTopics.FirstOrDefault(t => NormalizeSearchText(t.Name) == normalized);
        if (match is not null)
        {
            return (new TopicDto(match.Id, match.Name), null);
        }

        var topic = new Topic
        {
            Name = req.Name.Trim(),
            DateCreate = DateTime.UtcNow,
            IdStatus = true
        };

        db.Topics.Add(topic);
        await db.SaveChangesAsync();
        return (new TopicDto(topic.Id, topic.Name), null);
    }

    public async Task<IReadOnlyList<BookStatusDto>> GetStatusesAsync()
    {
        return await db.BookStatuses
            .AsNoTracking()
            .OrderBy(s => s.Id)
            .Select(s => new BookStatusDto(s.Id, s.Name))
            .ToListAsync();
    }

    private async Task<Shelf> ResolveOrCreateShelfAsync(string rawName)
    {
        var cleaned = rawName.Trim();
        var normalized = NormalizeSearchText(cleaned);
        var shelves = await db.Shelves.ToListAsync();

        var existing = shelves.FirstOrDefault(s =>
            NormalizeSearchText(s.Name) == normalized
            || NormalizeSearchText(s.Name.Replace("Estante ", "", StringComparison.OrdinalIgnoreCase)) == normalized);

        if (existing is not null)
        {
            return existing;
        }

        var formattedName = cleaned.StartsWith("Estante", StringComparison.OrdinalIgnoreCase)
            ? cleaned
            : $"Estante {cleaned}";

        var newShelf = new Shelf
        {
            Name = formattedName,
            DateCreate = DateTime.UtcNow,
            IdStatus = true
        };

        db.Shelves.Add(newShelf);
        await db.SaveChangesAsync();
        return newShelf;
    }

    private async Task SyncBookTopicsAsync(int bookId, IReadOnlyList<string> rawTopics)
    {
        var cleanedNames = rawTopics
            .SelectMany(t => t.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
            .Where(t => !string.IsNullOrWhiteSpace(t))
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();

        var existingLinks = await db.BookTopics
            .Where(bt => bt.BookId == bookId)
            .ToListAsync();

        if (existingLinks.Count > 0)
        {
            db.BookTopics.RemoveRange(existingLinks);
            await db.SaveChangesAsync();
        }

        if (cleanedNames.Count == 0)
        {
            return;
        }

        var allTopics = await db.Topics.ToListAsync();
        foreach (var topicName in cleanedNames)
        {
            var norm = NormalizeSearchText(topicName);
            var topic = allTopics.FirstOrDefault(t => NormalizeSearchText(t.Name) == norm);
            if (topic is null)
            {
                topic = new Topic
                {
                    Name = topicName.Trim(),
                    DateCreate = DateTime.UtcNow,
                    IdStatus = true
                };
                db.Topics.Add(topic);
                await db.SaveChangesAsync();
                allTopics.Add(topic);
            }

            db.BookTopics.Add(new BookTopic
            {
                BookId = bookId,
                TopicId = topic.Id,
                DateCreate = DateTime.UtcNow,
                IdStatus = true
            });
        }

        await db.SaveChangesAsync();
    }

    private static BookDto MapToDto(Book b)
    {
        var topics = b.BookTopics
            .Where(bt => bt.Topic != null)
            .Select(bt => bt.Topic!.Name)
            .Distinct()
            .ToList();

        var cleanFolio = NormalizeFolio(b.Folio);

        return new BookDto(
            b.Id,
            b.Title,
            b.Note,
            b.Author,
            cleanFolio,
            b.Dewey,
            b.Cutter,
            b.StatusId,
            b.Status?.Name ?? "Disponible",
            b.ShelfId,
            b.Shelf?.Name ?? "General",
            b.StatusId switch
            {
                1 => "6 de 8 copias libres",
                2 => "En préstamo (1 ejemplar)",
                3 => "En taller de encuadernación",
                4 => "0 disponibles (Baja definitiva)",
                5 => "En revisión de catalogación",
                _ => "Consultar en mostrador"
            },
            b.StatusId switch
            {
                1 => 75,
                2 => 25,
                3 => 40,
                4 => 0,
                5 => 100,
                _ => 50
            },
            topics
        );
    }
}
