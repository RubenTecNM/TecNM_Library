namespace TecNM.Api.Features.Books;

public class Book
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Note { get; set; }
    public string? Author { get; set; }
    public string Folio { get; set; } = string.Empty;
    public string Dewey { get; set; } = string.Empty;
    public string Cutter { get; set; } = string.Empty;
    public int StatusId { get; set; }
    public int ShelfId { get; set; }

    public int IdUserCreate { get; set; } = 1;
    public DateTime DateCreate { get; set; } = DateTime.UtcNow;
    public int? IdUserUpdate { get; set; }
    public DateTime? DateUpdate { get; set; }
    public int? IdUserDelete { get; set; }
    public DateTime? DateDelete { get; set; }
    public bool IdStatus { get; set; } = true;

    public BookStatus? Status { get; set; }
    public Shelf? Shelf { get; set; }
    public ICollection<BookAuthor> BookAuthors { get; set; } = new List<BookAuthor>();
    public ICollection<BookTopic> BookTopics { get; set; } = new List<BookTopic>();
    public ICollection<Loan> Loans { get; set; } = new List<Loan>();
}

