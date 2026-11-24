namespace TecNM.Api.Features.Books;

public class Visit
{
    public int Id { get; set; }
    public int BorrowerId { get; set; }
    public int ServiceId { get; set; }
    public DateTime EntryDate { get; set; } = DateTime.UtcNow;
    public DateTime? ExitDate { get; set; }
    public string? Notes { get; set; }

    public int IdUserCreate { get; set; } = 1;
    public DateTime DateCreate { get; set; } = DateTime.UtcNow;
    public int? IdUserUpdate { get; set; }
    public DateTime? DateUpdate { get; set; }
    public int? IdUserDelete { get; set; }
    public DateTime? DateDelete { get; set; }
    public bool IdStatus { get; set; } = true;

    public Borrower? Borrower { get; set; }
    public Service? Service { get; set; }
}
