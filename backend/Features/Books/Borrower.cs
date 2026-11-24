namespace TecNM.Api.Features.Books;

public class Borrower
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string StudentId { get; set; } = string.Empty;
    public string Major { get; set; } = string.Empty;
    public string? Semester { get; set; }
    public string Time { get; set; } = string.Empty;
    public string Gender { get; set; } = string.Empty;
    public string? PhoneNumber { get; set; }
    public string Email { get; set; } = string.Empty;
    public int RoleId { get; set; } = 3;

    public int IdUserCreate { get; set; } = 1;
    public DateTime DateCreate { get; set; } = DateTime.UtcNow;
    public int? IdUserUpdate { get; set; }
    public DateTime? DateUpdate { get; set; }
    public int? IdUserDelete { get; set; }
    public DateTime? DateDelete { get; set; }
    public bool IdStatus { get; set; } = true;

    public Role? Role { get; set; }
    public ICollection<Loan> Loans { get; set; } = new List<Loan>();
    public ICollection<Visit> Visits { get; set; } = new List<Visit>();
}

