using Microsoft.AspNetCore.Mvc;

namespace TecNM.Api.Features.Books;

[ApiController]
[Route("api/[controller]")]
public class BooksController(IBooksService booksService) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<BookDto>>> GetBooks(
        [FromQuery] string? search = null,
        [FromQuery] string? field = "all",
        [FromQuery] string? status = "all",
        [FromQuery] string? sortBy = "dewey",
        CancellationToken cancellationToken = default)
    {
        var query = new BookSearchQuery(search, field, status, sortBy);
        var result = await booksService.SearchBooksAsync(query, cancellationToken);
        return Ok(result);
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<BookDto>> GetBook(int id, CancellationToken cancellationToken = default)
    {
        var book = await booksService.GetBookByIdAsync(id, cancellationToken);
        if (book is null)
        {
            return NotFound(new { message = "Ejemplar no encontrado." });
        }

        return Ok(book);
    }

    [HttpGet("metrics")]
    public async Task<ActionResult<BookMetricsDto>> GetMetrics(CancellationToken cancellationToken = default)
    {
        var metrics = await booksService.GetMetricsAsync(cancellationToken);
        return Ok(metrics);
    }

    [HttpPost]
    public async Task<ActionResult<BookDto>> CreateBook(
        [FromBody] CreateBookRequest req,
        CancellationToken cancellationToken = default)
    {
        var (book, errorMessage, statusCode) = await booksService.CreateBookAsync(req, cancellationToken);
        if (book is null)
        {
            return StatusCode(statusCode, new { message = errorMessage ?? "No se pudo registrar el ejemplar." });
        }

        return CreatedAtAction(nameof(GetBook), new { id = book.Id }, book);
    }

    [HttpPut("{id:int}/status")]
    public async Task<IActionResult> UpdateStatus(
        int id,
        [FromBody] UpdateBookStatusRequest req,
        CancellationToken cancellationToken = default)
    {
        var (success, errorMessage, statusCode) = await booksService.UpdateStatusAsync(id, req, cancellationToken);
        if (!success)
        {
            return StatusCode(statusCode, new { message = errorMessage ?? "No se pudo actualizar el estado." });
        }

        return Ok(new { message = "Estado actualizado correctamente.", bookId = id, statusId = req.StatusId });
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> SoftDelete(int id, CancellationToken cancellationToken = default)
    {
        var deleted = await booksService.SoftDeleteAsync(id, cancellationToken);
        if (!deleted)
        {
            return NotFound(new { message = "Ejemplar no encontrado." });
        }

        return Ok(new { message = "Ejemplar eliminado lógicamente (soft delete)." });
    }

    [HttpGet("shelves")]
    public async Task<ActionResult<IReadOnlyList<ShelfDto>>> GetShelves(CancellationToken cancellationToken = default)
    {
        var shelves = await booksService.GetShelvesAsync(cancellationToken);
        return Ok(shelves);
    }

    [HttpGet("statuses")]
    public async Task<ActionResult<IReadOnlyList<BookStatusDto>>> GetStatuses(CancellationToken cancellationToken = default)
    {
        var statuses = await booksService.GetStatusesAsync(cancellationToken);
        return Ok(statuses);
    }
}
