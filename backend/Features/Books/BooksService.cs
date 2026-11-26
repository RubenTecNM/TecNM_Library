using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore;
using TecNM.Api.Data;

namespace TecNM.Api.Features.Books;

public interface IBooksService
{
    Task<IReadOnlyList<BookDto>> SearchBooksAsync(BookSearchQuery query, CancellationToken cancellationToken = default);
    Task<BookDto?> GetBookByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<BookMetricsDto> GetMetricsAsync(CancellationToken cancellationToken = default);
    Task<(BookDto? Book, string? ErrorMessage, int StatusCode)> CreateBookAsync(CreateBookRequest req, CancellationToken cancellationToken = default);
    Task<(bool Success, string? ErrorMessage, int StatusCode)> UpdateStatusAsync(int id, UpdateBookStatusRequest req, CancellationToken cancellationToken = default);
    Task<bool> SoftDeleteAsync(int id, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<ShelfDto>> GetShelvesAsync(CancellationToken cancellationToken = default);
    Task<IReadOnlyList<BookStatusDto>> GetStatusesAsync(CancellationToken cancellationToken = default);
}

public sealed class BooksService(TecNMDbContext db) : IBooksService
{
    private const int MaxSearchTokens = 10;

    private sealed record SearchParameter(string Value);

    private static readonly (string Accented, string Plain)[] SpanishAccentReplacements =
    [
        ("á", "a"),
        ("é", "e"),
        ("í", "i"),
        ("ó", "o"),
        ("ú", "u"),
        ("ü", "u"),
    ];

    public async Task<IReadOnlyList<BookDto>> SearchBooksAsync(
        BookSearchQuery searchQuery,
        CancellationToken cancellationToken = default)
    {
        var query = db.Books
            .AsNoTracking()
            .Include(b => b.Status)
            .Include(b => b.Shelf)
            .Include(b => b.BookAuthors.Where(ba => ba.IdStatus))
                .ThenInclude(ba => ba.Author)
            .Include(b => b.BookTopics.Where(bt => bt.IdStatus))
                .ThenInclude(bt => bt.Topic)
            .AsSplitQuery();

        query = ApplyStatusFilter(query, searchQuery.Status);
        query = ApplyRealtimeSearchFilter(query, searchQuery.Search, searchQuery.Field);
        query = ApplySorting(query, searchQuery.SortBy);

        var books = await query.ToListAsync(cancellationToken);

        return books.Select(MapToDto).ToList();
    }

    public async Task<BookDto?> GetBookByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        var book = await db.Books
            .AsNoTracking()
            .Include(b => b.Status)
            .Include(b => b.Shelf)
            .Include(b => b.BookAuthors.Where(ba => ba.IdStatus))
                .ThenInclude(ba => ba.Author)
            .Include(b => b.BookTopics.Where(bt => bt.IdStatus))
                .ThenInclude(bt => bt.Topic)
            .AsSplitQuery()
            .FirstOrDefaultAsync(b => b.Id == id, cancellationToken);

        return book is null ? null : MapToDto(book);
    }

    public async Task<BookMetricsDto> GetMetricsAsync(CancellationToken cancellationToken = default)
    {
        var grouped = await db.Books
            .AsNoTracking()
            .GroupBy(b => b.StatusId)
            .Select(g => new { StatusId = g.Key, Count = g.Count() })
            .ToListAsync(cancellationToken);

        var counts = grouped.ToDictionary(x => x.StatusId, x => x.Count);
        var total = grouped.Sum(x => x.Count);

        return new BookMetricsDto(
            TotalBooks: total,
            AvailableCount: counts.GetValueOrDefault(1),
            BorrowedCount: counts.GetValueOrDefault(2),
            RepairCount: counts.GetValueOrDefault(3),
            DiscardCount: counts.GetValueOrDefault(4),
            CatalogCount: counts.GetValueOrDefault(5)
        );
    }

    public async Task<(BookDto? Book, string? ErrorMessage, int StatusCode)> CreateBookAsync(
        CreateBookRequest req,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(req.Title) || string.IsNullOrWhiteSpace(req.Folio))
        {
            return (null, "Título y Folio son obligatorios.", StatusCodes.Status400BadRequest);
        }

        var normalizedFolio = req.Folio.Trim();
        var exists = await db.Books.AnyAsync(b => b.Folio == normalizedFolio, cancellationToken);
        if (exists)
        {
            return (null, $"El folio '{normalizedFolio}' ya se encuentra registrado.", StatusCodes.Status409Conflict);
        }

        var statusId = req.StatusId > 0 ? req.StatusId : 1;
        var shelfId = req.ShelfId > 0 ? req.ShelfId : 1;

        var status = await db.BookStatuses.AsNoTracking().FirstOrDefaultAsync(s => s.Id == statusId, cancellationToken);
        var shelf = await db.Shelves.AsNoTracking().FirstOrDefaultAsync(s => s.Id == shelfId, cancellationToken);

        if (status is null)
        {
            return (null, "El estatus seleccionado no existe en el catálogo.", StatusCodes.Status400BadRequest);
        }

        if (shelf is null)
        {
            return (null, "El estante seleccionado no existe en el catálogo.", StatusCodes.Status400BadRequest);
        }

        var book = new Book
        {
            Title = req.Title.Trim(),
            Author = req.Author?.Trim(),
            Note = req.Note?.Trim(),
            Folio = normalizedFolio,
            Dewey = req.Dewey.Trim(),
            Cutter = req.Cutter.Trim(),
            StatusId = statusId,
            ShelfId = shelfId,
            DateCreate = DateTime.UtcNow,
            IdStatus = true
        };

        db.Books.Add(book);
        await db.SaveChangesAsync(cancellationToken);

        book.Status = status;
        book.Shelf = shelf;
        return (MapToDto(book), null, StatusCodes.Status201Created);
    }

    public async Task<(bool Success, string? ErrorMessage, int StatusCode)> UpdateStatusAsync(
        int id,
        UpdateBookStatusRequest req,
        CancellationToken cancellationToken = default)
    {
        var book = await db.Books.FirstOrDefaultAsync(b => b.Id == id, cancellationToken);
        if (book is null)
        {
            return (false, "Ejemplar no encontrado.", StatusCodes.Status404NotFound);
        }

        var statusExists = await db.BookStatuses.AsNoTracking().AnyAsync(s => s.Id == req.StatusId, cancellationToken);
        if (!statusExists)
        {
            return (false, "El estatus seleccionado no existe en el catálogo.", StatusCodes.Status400BadRequest);
        }

        book.StatusId = req.StatusId;
        if (!string.IsNullOrWhiteSpace(req.Note))
        {
            book.Note = req.Note.Trim();
        }
        book.DateUpdate = DateTime.UtcNow;

        await db.SaveChangesAsync(cancellationToken);
        return (true, null, StatusCodes.Status200OK);
    }

    public async Task<bool> SoftDeleteAsync(int id, CancellationToken cancellationToken = default)
    {
        var book = await db.Books.FirstOrDefaultAsync(b => b.Id == id, cancellationToken);
        if (book is null)
        {
            return false;
        }

        book.IdStatus = false;
        book.DateDelete = DateTime.UtcNow;

        await db.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<IReadOnlyList<ShelfDto>> GetShelvesAsync(CancellationToken cancellationToken = default)
    {
        return await db.Shelves
            .AsNoTracking()
            .Where(s => s.IdStatus)
            .OrderBy(s => s.Name)
            .Select(s => new ShelfDto(s.Id, s.Name))
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<BookStatusDto>> GetStatusesAsync(CancellationToken cancellationToken = default)
    {
        return await db.BookStatuses
            .AsNoTracking()
            .Where(s => s.IdStatus)
            .OrderBy(s => s.Id)
            .Select(s => new BookStatusDto(s.Id, s.Name))
            .ToListAsync(cancellationToken);
    }

    private static IQueryable<Book> ApplyStatusFilter(IQueryable<Book> query, string? status)
    {
        if (string.IsNullOrWhiteSpace(status) || status.Equals("all", StringComparison.OrdinalIgnoreCase))
        {
            return query;
        }

        var normalized = NormalizeSearchText(status);
        return normalized switch
        {
            "1" or "disponible" => query.Where(b => b.StatusId == 1),
            "2" or "prestado" => query.Where(b => b.StatusId == 2),
            "3" or "reparacion" or "en reparacion" => query.Where(b => b.StatusId == 3),
            "4" or "baja" or "en proceso de baja" => query.Where(b => b.StatusId == 4),
            "5" or "catalogo" or "en catalogo" => query.Where(b => b.StatusId == 5),
            _ => query
        };
    }

    private static IQueryable<Book> ApplyRealtimeSearchFilter(
        IQueryable<Book> query,
        string? search,
        string? field)
    {
        if (string.IsNullOrWhiteSpace(search))
        {
            return query;
        }

        var tokens = search
            .Split((char[]?)null, StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
            .Select(NormalizeSearchText)
            .Where(t => !string.IsNullOrEmpty(t))
            .Distinct()
            .Take(MaxSearchTokens)
            .ToArray();

        if (tokens.Length == 0)
        {
            return query;
        }

        var targetField = field?.Trim().ToLowerInvariant() ?? "all";

        foreach (var token in tokens)
        {
            var predicate = BuildTokenPredicate(token, targetField);
            query = query.Where(predicate);
        }

        return query;
    }

    private static Expression<Func<Book, bool>> BuildTokenPredicate(string normalizedToken, string field)
    {
        var bookParam = Expression.Parameter(typeof(Book), "b");

        Expression titleMatch = BuildNormalizedContains(Expression.Property(bookParam, nameof(Book.Title)), normalizedToken, isNullable: false);
        Expression authorColumnMatch = BuildNormalizedContains(Expression.Property(bookParam, nameof(Book.Author)), normalizedToken, isNullable: true);
        Expression noteMatch = BuildNormalizedContains(Expression.Property(bookParam, nameof(Book.Note)), normalizedToken, isNullable: true);
        Expression deweyMatch = BuildNormalizedContains(Expression.Property(bookParam, nameof(Book.Dewey)), normalizedToken, isNullable: false);
        Expression cutterMatch = BuildNormalizedContains(Expression.Property(bookParam, nameof(Book.Cutter)), normalizedToken, isNullable: false);
        Expression folioMatch = BuildNormalizedContains(Expression.Property(bookParam, nameof(Book.Folio)), normalizedToken, isNullable: false);
        Expression shelfMatch = BuildNestedPropertyMatch(bookParam, nameof(Book.Shelf), nameof(Shelf.Name), normalizedToken);
        Expression statusMatch = BuildNestedPropertyMatch(bookParam, nameof(Book.Status), nameof(BookStatus.Name), normalizedToken);
        Expression coAuthorMatch = BuildBookAuthorsMatch(bookParam, normalizedToken);
        Expression topicMatch = BuildBookTopicsMatch(bookParam, normalizedToken);

        Expression authorMatch = Expression.OrElse(authorColumnMatch, coAuthorMatch);

        Expression body = field switch
        {
            "title" => titleMatch,
            "author" => authorMatch,
            "dewey" => Expression.OrElse(deweyMatch, cutterMatch),
            "cutter" => cutterMatch,
            "barcode" or "folio" => folioMatch,
            "shelf" => shelfMatch,
            "topic" => topicMatch,
            _ => CombineOr(
                titleMatch,
                authorMatch,
                topicMatch,
                noteMatch,
                deweyMatch,
                cutterMatch,
                folioMatch,
                shelfMatch,
                statusMatch
            )
        };

        return Expression.Lambda<Func<Book, bool>>(body, bookParam);
    }

    private static Expression BuildNormalizedContains(Expression stringProperty, string normalizedToken, bool isNullable)
    {
        var toLowerMethod = typeof(string).GetMethod(nameof(string.ToLower), Type.EmptyTypes)!;
        var replaceMethod = typeof(string).GetMethod(nameof(string.Replace), [typeof(string), typeof(string)])!;
        var containsMethod = typeof(string).GetMethod(nameof(string.Contains), [typeof(string)])!;

        Expression normalizedExpr = Expression.Call(stringProperty, toLowerMethod);
        foreach (var (accented, plain) in SpanishAccentReplacements)
        {
            normalizedExpr = Expression.Call(
                normalizedExpr,
                replaceMethod,
                Expression.Constant(accented),
                Expression.Constant(plain));
        }

        var tokenValueExpr = Expression.Property(
            Expression.Constant(new SearchParameter(normalizedToken)),
            nameof(SearchParameter.Value));
        Expression containsExpr = Expression.Call(normalizedExpr, containsMethod, tokenValueExpr);

        if (!isNullable)
        {
            return containsExpr;
        }

        var notNullExpr = Expression.NotEqual(stringProperty, Expression.Constant(null, typeof(string)));
        return Expression.AndAlso(notNullExpr, containsExpr);
    }

    private static Expression BuildNestedPropertyMatch(
        ParameterExpression bookParam,
        string navPropertyName,
        string stringPropertyName,
        string normalizedToken)
    {
        var navProp = Expression.Property(bookParam, navPropertyName);
        var navNotNull = Expression.NotEqual(navProp, Expression.Constant(null, navProp.Type));
        var innerProp = Expression.Property(navProp, stringPropertyName);
        var match = BuildNormalizedContains(innerProp, normalizedToken, isNullable: false);
        return Expression.AndAlso(navNotNull, match);
    }

    private static Expression BuildBookAuthorsMatch(ParameterExpression bookParam, string normalizedToken)
    {
        var baParam = Expression.Parameter(typeof(BookAuthor), "ba");
        var baActive = Expression.Equal(
            Expression.Property(baParam, nameof(BookAuthor.IdStatus)),
            Expression.Constant(true));
        var authorNav = Expression.Property(baParam, nameof(BookAuthor.Author));
        var authorNotNull = Expression.NotEqual(authorNav, Expression.Constant(null, typeof(Author)));

        var firstNameMatch = BuildNormalizedContains(Expression.Property(authorNav, nameof(Author.Name)), normalizedToken, isNullable: false);
        var lastNameMatch = BuildNormalizedContains(Expression.Property(authorNav, nameof(Author.LastName)), normalizedToken, isNullable: false);

        var predicateBody = Expression.AndAlso(
            baActive,
            Expression.AndAlso(authorNotNull, Expression.OrElse(firstNameMatch, lastNameMatch)));

        var predicate = Expression.Lambda<Func<BookAuthor, bool>>(predicateBody, baParam);
        var anyMethod = typeof(Enumerable)
            .GetMethods()
            .First(m => m.Name == nameof(Enumerable.Any) && m.GetParameters().Length == 2)
            .MakeGenericMethod(typeof(BookAuthor));

        return Expression.Call(anyMethod, Expression.Property(bookParam, nameof(Book.BookAuthors)), predicate);
    }

    private static Expression BuildBookTopicsMatch(ParameterExpression bookParam, string normalizedToken)
    {
        var btParam = Expression.Parameter(typeof(BookTopic), "bt");
        var btActive = Expression.Equal(
            Expression.Property(btParam, nameof(BookTopic.IdStatus)),
            Expression.Constant(true));
        var topicNav = Expression.Property(btParam, nameof(BookTopic.Topic));
        var topicNotNull = Expression.NotEqual(topicNav, Expression.Constant(null, typeof(Topic)));
        var topicNameMatch = BuildNormalizedContains(Expression.Property(topicNav, nameof(Topic.Name)), normalizedToken, isNullable: false);

        var predicateBody = Expression.AndAlso(btActive, Expression.AndAlso(topicNotNull, topicNameMatch));
        var predicate = Expression.Lambda<Func<BookTopic, bool>>(predicateBody, btParam);

        var anyMethod = typeof(Enumerable)
            .GetMethods()
            .First(m => m.Name == nameof(Enumerable.Any) && m.GetParameters().Length == 2)
            .MakeGenericMethod(typeof(BookTopic));

        return Expression.Call(anyMethod, Expression.Property(bookParam, nameof(Book.BookTopics)), predicate);
    }

    private static Expression CombineOr(params Expression[] expressions)
    {
        return expressions.Aggregate(Expression.OrElse);
    }

    private static IQueryable<Book> ApplySorting(IQueryable<Book> query, string? sortBy)
    {
        return (sortBy?.Trim().ToLowerInvariant()) switch
        {
            "status" => query.OrderBy(b => b.StatusId).ThenBy(b => b.Title),
            "barcode" or "folio" => query.OrderBy(b => b.Folio).ThenBy(b => b.Title),
            "relevance" => query.OrderBy(b => b.Title).ThenBy(b => b.Dewey),
            _ => query.OrderBy(b => b.Dewey).ThenBy(b => b.Title)
        };
    }

    private static string NormalizeSearchText(string value)
    {
        var normalized = value.Trim().ToLowerInvariant();
        foreach (var (accented, plain) in SpanishAccentReplacements)
        {
            normalized = normalized.Replace(accented, plain, StringComparison.Ordinal);
        }

        return normalized;
    }

    private static BookDto MapToDto(Book book)
    {
        var authorText = !string.IsNullOrWhiteSpace(book.Author)
            ? book.Author
            : string.Join(
                ", ",
                book.BookAuthors
                    .Where(ba => ba.IdStatus && ba.Author is not null)
                    .Select(ba => $"{ba.Author!.Name} {ba.Author.LastName}".Trim()));

        var topics = book.BookTopics
            .Where(bt => bt.IdStatus && bt.Topic is not null)
            .Select(bt => bt.Topic!.Name)
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();

        return new BookDto(
            book.Id,
            book.Title,
            book.Note,
            string.IsNullOrWhiteSpace(authorText) ? "Autor institucional" : authorText,
            book.Folio,
            book.Dewey,
            book.Cutter,
            book.StatusId,
            book.Status?.Name ?? "Desconocido",
            book.ShelfId,
            book.Shelf?.Name ?? "General",
            book.StatusId switch
            {
                1 => "Disponible para consulta",
                2 => "En préstamo activo",
                3 => "En taller de encuadernación",
                4 => "0 disponibles (Baja definitiva)",
                5 => "En revisión de catalogación",
                _ => "Consultar en mostrador"
            },
            book.StatusId switch
            {
                1 => 80,
                2 => 25,
                3 => 40,
                4 => 10,
                5 => 100,
                _ => 50
            },
            topics
        );
    }
}
