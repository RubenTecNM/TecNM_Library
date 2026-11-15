namespace TecNM.Api.Features.Books;

public class Topic
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

    public ICollection<BookTopic> BookTopics { get; set; } = new List<BookTopic>();
}

