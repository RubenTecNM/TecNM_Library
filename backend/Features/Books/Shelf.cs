namespace TecNM.Api.Features.Books;

public class Shelf
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;

    public int IdUserCreate { get; set; } = 1;
    public DateTime DateCreate { get; set; } = DateTime.UtcNow;
    public int? IdUserUpdate { get; set; }
    public DateTime? DateUpdate { get; set; }
    public int? IdUserDelete { get; set; }
    public DateTime? DateDelete { get; set; }
    public bool IdStatus { get; set; } = true;

    public ICollection<Book> Books { get; set; } = new List<Book>();
}

