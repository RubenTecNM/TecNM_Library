using Microsoft.AspNetCore.Mvc;

namespace TecNM.Api.Features.Books;

[ApiController]
[Route("api/[controller]")]
public sealed class BooksController(IBookService bookService) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IEnumerable<BookDto>>> GetBooks(
        [FromQuery] string? search = null,
        [FromQuery] string? field = "all",
        [FromQuery] string? status = "all",
        [FromQuery] string? sortBy = "dewey")
    {
        var books = await bookService.GetBooksAsync(search, field, status, sortBy);
        return Ok(books);
    }

    [HttpGet("next-folio")]
    public async Task<ActionResult<NextFolioDto>> GetNextFolio()
    {
        var dto = await bookService.GetNextAvailableFolioAsync();
        return Ok(dto);
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<BookDto>> GetBook(int id)
    {
        var dto = await bookService.GetBookByIdAsync(id);
        if (dto is null)
        {
            return NotFound(new { message = "Ejemplar no encontrado." });
        }

        return Ok(dto);
    }

    [HttpGet("metrics")]
    public async Task<ActionResult<BookMetricsDto>> GetMetrics()
    {
        var metrics = await bookService.GetMetricsAsync();
        return Ok(metrics);
    }

    [HttpPost]
    public async Task<ActionResult<BookDto>> CreateBook([FromBody] CreateBookRequest req)
    {
        var (book, error, isConflict) = await bookService.CreateBookAsync(req);
        if (error is not null)
        {
            return isConflict
                ? Conflict(new { message = error })
                : BadRequest(new { message = error });
        }

        return CreatedAtAction(nameof(GetBook), new { id = book!.Id }, book);
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult<BookDto>> UpdateBook(int id, [FromBody] UpdateBookRequest req)
    {
        var (book, error, isNotFound, isConflict) = await bookService.UpdateBookAsync(id, req);
        if (isNotFound)
        {
            return NotFound(new { message = error });
        }

        if (error is not null)
        {
            return isConflict
                ? Conflict(new { message = error })
                : BadRequest(new { message = error });
        }

        return Ok(book);
    }

    [HttpPut("{id:int}/status")]
    public async Task<IActionResult> UpdateStatus(int id, [FromBody] UpdateBookStatusRequest req)
    {
        var updated = await bookService.UpdateStatusAsync(id, req);
        if (!updated)
        {
            return NotFound(new { message = "Ejemplar no encontrado." });
        }

        return Ok(new { message = "Estado actualizado correctamente.", bookId = id, statusId = req.StatusId });
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> SoftDelete(int id)
    {
        var deleted = await bookService.SoftDeleteAsync(id);
        if (!deleted)
        {
            return NotFound(new { message = "Ejemplar no encontrado." });
        }

        return Ok(new { message = "Ejemplar eliminado lógicamente (soft delete)." });
    }

    [HttpGet("shelves")]
    public async Task<ActionResult<IEnumerable<ShelfDto>>> GetShelves()
    {
        var shelves = await bookService.GetShelvesAsync();
        return Ok(shelves);
    }

    [HttpPost("shelves")]
    public async Task<ActionResult<ShelfDto>> CreateShelf([FromBody] CreateShelfRequest req)
    {
        var (shelf, error) = await bookService.CreateShelfAsync(req);
        if (error is not null)
        {
            return BadRequest(new { message = error });
        }

        return Ok(shelf);
    }

    [HttpGet("topics")]
    public async Task<ActionResult<IEnumerable<TopicDto>>> GetTopics()
    {
        var topics = await bookService.GetTopicsAsync();
        return Ok(topics);
    }

    [HttpPost("topics")]
    public async Task<ActionResult<TopicDto>> CreateTopic([FromBody] CreateTopicRequest req)
    {
        var (topic, error) = await bookService.CreateTopicAsync(req);
        if (error is not null)
        {
            return BadRequest(new { message = error });
        }

        return Ok(topic);
    }

    [HttpGet("statuses")]
    public async Task<ActionResult<IEnumerable<BookStatusDto>>> GetStatuses()
    {
        var statuses = await bookService.GetStatusesAsync();
        return Ok(statuses);
    }
}
