namespace TecNM.Api.Features.Books;

public class Loan
{
    public int Id { get; set; }
    public int BookId { get; set; }
    public int BorrowerId { get; set; }
    public DateOnly StartDate { get; set; } = DateOnly.FromDateTime(DateTime.UtcNow);
    public DateOnly DueDate { get; set; }
    public DateOnly? ReturnDate { get; set; }
    public string Responsible { get; set; } = string.Empty;

    public int IdUserCreate { get; set; } = 1;
    public DateTime DateCreate { get; set; } = DateTime.UtcNow;
    public int? IdUserUpdate { get; set; }
    public DateTime? DateUpdate { get; set; }
    public int? IdUserDelete { get; set; }
    public DateTime? DateDelete { get; set; }
    public bool IdStatus { get; set; } = true;

    public Book? Book { get; set; }
    public Borrower? Borrower { get; set; }
}

