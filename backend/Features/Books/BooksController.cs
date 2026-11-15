using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TecNM.Api.Data;

namespace TecNM.Api.Features.Books;

[ApiController]
[Route("api/[controller]")]
public class BooksController(TecNMDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IEnumerable<BookDto>>> GetBooks(
        [FromQuery] string? search = null,
        [FromQuery] string? field = "all",
        [FromQuery] string? status = "all",
        [FromQuery] string? sortBy = "dewey")
    {
        var query = db.Books
            .Include(b => b.Status)
            .Include(b => b.Shelf)
            .AsNoTracking();

        // Filtro por Estado
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

        // Filtro por Búsqueda y Campo
        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = search.Trim().ToLower();
            query = (field?.ToLowerInvariant()) switch
            {
                "title" => query.Where(b => b.Title.ToLower().Contains(term)),
                "author" => query.Where(b => (b.Author != null && b.Author.ToLower().Contains(term))),
                "dewey" => query.Where(b => b.Dewey.ToLower().Contains(term)),
                "barcode" or "folio" => query.Where(b => b.Folio.ToLower().Contains(term)),
                _ => query.Where(b => b.Title.ToLower().Contains(term)
                                   || (b.Author != null && b.Author.ToLower().Contains(term))
                                   || b.Dewey.ToLower().Contains(term)
                                   || b.Folio.ToLower().Contains(term)
                                   || (b.Shelf != null && b.Shelf.Name.ToLower().Contains(term)))
            };
        }

        // Ordenamiento
        query = (sortBy?.ToLowerInvariant()) switch
        {
            "status" => query.OrderBy(b => b.StatusId).ThenBy(b => b.Title),
            "barcode" or "folio" => query.OrderBy(b => b.Folio),
            _ => query.OrderBy(b => b.Dewey).ThenBy(b => b.Title)
        };

        var books = await query.ToListAsync();

        var result = books.Select(b => new BookDto(
            b.Id,
            b.Title,
            b.Note,
            b.Author,
            b.Folio,
            b.Dewey,
            b.Cutter,
            b.StatusId,
            b.Status?.Name ?? "Desconocido",
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
            }
        ));

        return Ok(result);
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<BookDto>> GetBook(int id)
    {
        var book = await db.Books
            .Include(b => b.Status)
            .Include(b => b.Shelf)
            .AsNoTracking()
            .FirstOrDefaultAsync(b => b.Id == id);

        if (book is null)
        {
            return NotFound(new { message = "Ejemplar no encontrado." });
        }

        var dto = new BookDto(
            book.Id,
            book.Title,
            book.Note,
            book.Author,
            book.Folio,
            book.Dewey,
            book.Cutter,
            book.StatusId,
            book.Status?.Name ?? "Desconocido",
            book.ShelfId,
            book.Shelf?.Name ?? "General",
            book.StatusId == 1 ? "6 de 8 copias libres" : "No disponible",
            book.StatusId == 1 ? 75 : 25
        );

        return Ok(dto);
    }

    [HttpGet("metrics")]
    public async Task<ActionResult<BookMetricsDto>> GetMetrics()
    {
        var books = await db.Books.AsNoTracking().ToListAsync();

        var metrics = new BookMetricsDto(
            TotalBooks: books.Count,
            AvailableCount: books.Count(b => b.StatusId == 1),
            BorrowedCount: books.Count(b => b.StatusId == 2),
            RepairCount: books.Count(b => b.StatusId == 3),
            DiscardCount: books.Count(b => b.StatusId == 4),
            CatalogCount: books.Count(b => b.StatusId == 5)
        );

        return Ok(metrics);
    }

    [HttpPost]
    public async Task<ActionResult<BookDto>> CreateBook([FromBody] CreateBookRequest req)
    {
        if (string.IsNullOrWhiteSpace(req.Title) || string.IsNullOrWhiteSpace(req.Folio))
        {
            return BadRequest(new { message = "Título y Folio son obligatorios." });
        }

        var exists = await db.Books.AnyAsync(b => b.Folio == req.Folio);
        if (exists)
        {
            return Conflict(new { message = $"El folio '{req.Folio}' ya se encuentra registrado." });
        }

        var book = new Book
        {
            Title = req.Title.Trim(),
            Author = req.Author?.Trim(),
            Note = req.Note?.Trim(),
            Folio = req.Folio.Trim(),
            Dewey = req.Dewey.Trim(),
            Cutter = req.Cutter.Trim(),
            StatusId = req.StatusId > 0 ? req.StatusId : 1,
            ShelfId = req.ShelfId > 0 ? req.ShelfId : 1,
            DateCreate = DateTime.UtcNow,
            IdStatus = true
        };

        db.Books.Add(book);
        await db.SaveChangesAsync();

        return CreatedAtAction(nameof(GetBook), new { id = book.Id }, new BookDto(
            book.Id,
            book.Title,
            book.Note,
            book.Author,
            book.Folio,
            book.Dewey,
            book.Cutter,
            book.StatusId,
            "Disponible",
            book.ShelfId,
            "Estante Asignado",
            "Disponible en acervo",
            100
        ));
    }

    [HttpPut("{id:int}/status")]
    public async Task<IActionResult> UpdateStatus(int id, [FromBody] UpdateBookStatusRequest req)
    {
        var book = await db.Books.FindAsync(id);
        if (book is null)
        {
            return NotFound(new { message = "Ejemplar no encontrado." });
        }

        book.StatusId = req.StatusId;
        if (!string.IsNullOrWhiteSpace(req.Note))
        {
            book.Note = req.Note;
        }
        book.DateUpdate = DateTime.UtcNow;

        await db.SaveChangesAsync();
        return Ok(new { message = "Estado actualizado correctamente.", bookId = id, statusId = req.StatusId });
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> SoftDelete(int id)
    {
        var book = await db.Books.FindAsync(id);
        if (book is null)
        {
            return NotFound(new { message = "Ejemplar no encontrado." });
        }

        book.IdStatus = false;
        book.DateDelete = DateTime.UtcNow;

        await db.SaveChangesAsync();
        return Ok(new { message = "Ejemplar eliminado lógicamente (soft delete)." });
    }

    [HttpGet("shelves")]
    public async Task<ActionResult<IEnumerable<ShelfDto>>> GetShelves()
    {
        var shelves = await db.Shelves
            .AsNoTracking()
            .Select(s => new ShelfDto(s.Id, s.Name))
            .ToListAsync();
        return Ok(shelves);
    }

    [HttpGet("statuses")]
    public async Task<ActionResult<IEnumerable<BookStatusDto>>> GetStatuses()
    {
        var statuses = await db.BookStatuses
            .AsNoTracking()
            .Select(s => new BookStatusDto(s.Id, s.Name))
            .ToListAsync();
        return Ok(statuses);
    }
}

