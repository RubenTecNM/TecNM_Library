namespace TecNM.Api.Features.Books;

public class BookAuthor
{
    public int Id { get; set; }
    public int BookId { get; set; }
    public int AuthorId { get; set; }

    public int IdUserCreate { get; set; } = 1;
    public DateTime DateCreate { get; set; } = DateTime.UtcNow;
    public int? IdUserUpdate { get; set; }
    public DateTime? DateUpdate { get; set; }
    public int? IdUserDelete { get; set; }
    public DateTime? DateDelete { get; set; }
    public bool IdStatus { get; set; } = true;

    public Book? Book { get; set; }
    public Author? Author { get; set; }
}

