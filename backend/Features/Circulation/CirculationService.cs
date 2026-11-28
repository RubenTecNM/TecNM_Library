using System.Globalization;
using Microsoft.EntityFrameworkCore;
using TecNM.Api.Data;
using TecNM.Api.Features.Books;

namespace TecNM.Api.Features.Circulation;

public interface ICirculationService
{
    Task<CirculationSummaryDto> GetCirculationSummaryAsync();
    Task<(CirculationLoanDto? Loan, string? Error, bool IsConflict)> CreateLoanAsync(CreateLoanRequest req);
    Task<(CirculationLoanDto? Loan, string? Error, bool IsNotFound)> ReturnLoanAsync(int loanId);
    Task<(CirculationLoanDto? Loan, string? Error, bool IsNotFound)> RenewLoanAsync(int loanId);
}

public sealed class CirculationService(TecNMDbContext db) : ICirculationService
{
    /// <summary>
    /// Plazo oficial de préstamo y renovación: 3 días.
    /// </summary>
    private const int StandardLoanDays = 3;
    private const int RenewalAdditionalDays = 3;

    private static readonly Dictionary<string, string> CareerLabels = new(StringComparer.OrdinalIgnoreCase)
    {
        ["sistemas"] = "Ing. en Sistemas",
        ["informatica"] = "Ing. Informática",
        ["industrial"] = "Ing. Industrial",
        ["mecatronica"] = "Ing. Mecatrónica",
        ["mecanica"] = "Ing. Mecánica",
        ["gestion"] = "Ing. en Gestión Empresarial",
        ["energias"] = "Ing. en Energías Renovables",
        ["electronica"] = "Ing. Electrónica",
    };

    public async Task<CirculationSummaryDto> GetCirculationSummaryAsync()
    {
        var now = DateTime.UtcNow;
        var today = DateOnly.FromDateTime(now);
        var loans = await db.Loans
            .Include(l => l.Book)
            .Include(l => l.Borrower)
            .AsNoTracking()
            .OrderByDescending(l => l.StartDate)
            .ThenByDescending(l => l.Id)
            .ToListAsync();

        var mappedLoans = loans.Select(l => MapLoanToDto(l, today)).ToList();

        var blockedStudents = mappedLoans
            .Where(l => l.HasEnrollmentBlock)
            .Select(l => new BlockedStudentAlertDto(
                LoanId: l.Id,
                BorrowerId: l.BorrowerId,
                StudentName: l.StudentName,
                ControlNumber: l.ControlNumber,
                CareerLabel: l.CareerLabel,
                Folio: l.Folio,
                BookTitle: l.BookTitle,
                DueDate: l.DueDate,
                DaysOverdue: l.DaysOverdue,
                BlockReason: l.EnrollmentBlockReason ?? "Bloqueo de inscripción activo por adeudo de ejemplar vencido."
            ))
            .ToList();

        var todayReturns = loans
            .Where(l => l.ReturnDate.HasValue && l.ReturnDate.Value == today)
            .OrderByDescending(l => l.DateUpdate ?? l.DateCreate)
            .Select(l =>
            {
                var wasOverdueWhenReturned = l.ReturnDate!.Value > l.DueDate;
                var control = l.Borrower?.InstitutionalId
                              ?? l.Borrower?.StudentId
                              ?? l.Borrower?.EmployeeId
                              ?? "S/N";
                var timeStamp = (l.DateUpdate ?? l.DateCreate).ToLocalTime();
                return new TodayReturnDto(
                    Id: l.Id,
                    Folio: BookService.NormalizeFolio(l.Book?.Folio),
                    BookTitle: l.Book?.Title ?? "Ejemplar bibliográfico",
                    Time: timeStamp.ToString("HH:mm 'hrs'", CultureInfo.InvariantCulture),
                    StudentInfo: $"{l.Borrower?.Name ?? "Estudiante"} (No. {control})",
                    Detail: wasOverdueWhenReturned
                        ? "Entregado con retraso • Bloqueo de inscripción liberado"
                        : "En buen estado • Sin bloqueo de inscripción",
                    WasBlocked: wasOverdueWhenReturned
                );
            })
            .ToList();

        var activeLoansCount = mappedLoans.Count(l => l.State != "devuelto");
        var scheduledTodayCount = mappedLoans.Count(l => l.IsDueToday);
        var overdueCount = mappedLoans.Count(l => l.IsOverdue);
        var historyCount = mappedLoans.Count(l => l.State == "devuelto");

        return new CirculationSummaryDto(
            ActiveLoans: activeLoansCount,
            ScheduledToday: scheduledTodayCount,
            OverdueLoans: overdueCount,
            BlockedStudentsCount: blockedStudents.Count,
            WebRenewals: mappedLoans.Count(l => l.State == "en_tiempo"),
            ReceivedToday: todayReturns.Count,
            HistoryCount: historyCount,
            Loans: mappedLoans,
            BlockedStudents: blockedStudents,
            TodayReturns: todayReturns
        );
    }

    public async Task<(CirculationLoanDto? Loan, string? Error, bool IsConflict)> CreateLoanAsync(CreateLoanRequest req)
    {
        var cleanFolio = BookService.NormalizeFolio(req.Folio);
        if (string.IsNullOrWhiteSpace(cleanFolio) || string.IsNullOrWhiteSpace(req.ControlNumber) || string.IsNullOrWhiteSpace(req.StudentName))
        {
            return (null, "Folio del libro, Número de Control y Nombre del solicitante son obligatorios.", false);
        }

        var control = req.ControlNumber.Trim();
        var now = DateTime.UtcNow;
        var today = DateOnly.FromDateTime(now);

        // Verificar si el estudiante tiene actualmente un bloqueo de inscripción por libro vencido
        var borrower = await db.Borrowers
            .FirstOrDefaultAsync(b => b.StudentId == control || b.EmployeeId == control || b.InstitutionalId == control);

        if (borrower is not null)
        {
            var hasOverdueLoan = await db.Loans
                .AnyAsync(l => l.BorrowerId == borrower.Id && l.ReturnDate == null && l.DueDate < today);

            if (hasOverdueLoan)
            {
                return (null, $"BLOQUEO DE INSCRIPCIÓN ACTIVO: El solicitante {borrower.Name} ({control}) tiene un ejemplar vencido pendiente de entrega. Debe devolverlo para liberar su bloqueo.", true);
            }
        }
        else
        {
            var isTeacherOrStaff = !char.IsDigit(control[0])
                || string.Equals(req.BorrowerType, "Docente", StringComparison.OrdinalIgnoreCase)
                || string.Equals(req.BorrowerType, "Administrativo", StringComparison.OrdinalIgnoreCase);

            var careerLabel = CareerLabels.TryGetValue(req.CareerKey ?? "sistemas", out var label)
                ? label
                : "Ing. en Sistemas Computacionales";

            borrower = new Borrower
            {
                Name = req.StudentName.Trim(),
                BorrowerType = isTeacherOrStaff ? "Docente" : "Alumno",
                StudentId = isTeacherOrStaff ? null : control,
                EmployeeId = isTeacherOrStaff ? control : null,
                Major = careerLabel,
                Semester = isTeacherOrStaff ? null : "Semestre Vigente",
                Time = "Matutino",
                Gender = "Masculino",
                Email = $"{control.ToLowerInvariant().Replace("-", "")}@monclova.tecnm.mx",
                RoleId = 3,
                DateCreate = now,
                IdStatus = true
            };

            db.Borrowers.Add(borrower);
            await db.SaveChangesAsync();
        }

        // Buscar o registrar el libro por folio
        var book = await db.Books
            .FirstOrDefaultAsync(b => b.Folio == cleanFolio || b.Folio == "#" + cleanFolio);

        if (book is null)
        {
            if (int.TryParse(cleanFolio, out var numericFolio) && numericFolio < 5000)
            {
                return (null, "Los folios de libros nuevos deben ser a partir del 5000 en adelante.", false);
            }

            book = new Book
            {
                Title = string.IsNullOrWhiteSpace(req.BookTitle) ? $"Ejemplar #{cleanFolio}" : req.BookTitle.Trim(),
                Author = "Acervo TecNM Monclova",
                Note = "Préstamo de mostrador",
                Folio = cleanFolio,
                Dewey = "005.1",
                Cutter = ".T42",
                StatusId = 2, // Prestado
                ShelfId = 1,
                DateCreate = now,
                IdStatus = true
            };
            db.Books.Add(book);
            await db.SaveChangesAsync();
        }
        else
        {
            var activeLoanOnBook = await db.Loans
                .AnyAsync(l => l.BookId == book.Id && l.ReturnDate == null);

            if (activeLoanOnBook)
            {
                return (null, $"El ejemplar con folio {cleanFolio} ya se encuentra en un préstamo activo.", true);
            }

            book.StatusId = 2; // Prestado
            book.DateUpdate = now;
        }

        // Plazo oficial: 3 días a partir de la fecha de préstamo
        var loan = new Loan
        {
            BookId = book.Id,
            BorrowerId = borrower.Id,
            StartDate = today,
            DueDate = today.AddDays(StandardLoanDays),
            ReturnDate = null,
            Responsible = "Lic. Martha Elena Vázquez Torres",
            DateCreate = now,
            IdStatus = true
        };

        db.Loans.Add(loan);
        await db.SaveChangesAsync();

        var createdLoan = await db.Loans
            .Include(l => l.Book)
            .Include(l => l.Borrower)
            .AsNoTracking()
            .FirstAsync(l => l.Id == loan.Id);

        return (MapLoanToDto(createdLoan, today), null, false);
    }

    public async Task<(CirculationLoanDto? Loan, string? Error, bool IsNotFound)> ReturnLoanAsync(int loanId)
    {
        var loan = await db.Loans
            .Include(l => l.Book)
            .Include(l => l.Borrower)
            .FirstOrDefaultAsync(l => l.Id == loanId);

        if (loan is null)
        {
            return (null, "Préstamo no encontrado.", true);
        }

        var now = DateTime.UtcNow;
        var today = DateOnly.FromDateTime(now);
        loan.ReturnDate = today;
        loan.DateUpdate = now;

        if (loan.Book is not null)
        {
            loan.Book.StatusId = 1; // Disponible nuevamente en inventario
            loan.Book.DateUpdate = now;
        }

        await db.SaveChangesAsync();
        return (MapLoanToDto(loan, today), null, false);
    }

    public async Task<(CirculationLoanDto? Loan, string? Error, bool IsNotFound)> RenewLoanAsync(int loanId)
    {
        var loan = await db.Loans
            .Include(l => l.Book)
            .Include(l => l.Borrower)
            .FirstOrDefaultAsync(l => l.Id == loanId);

        if (loan is null)
        {
            return (null, "Préstamo no encontrado.", true);
        }

        if (loan.ReturnDate.HasValue)
        {
            return (null, "No se puede renovar un préstamo que ya fue devuelto.", false);
        }

        var now = DateTime.UtcNow;
        var today = DateOnly.FromDateTime(now);
        // Si ya estaba vencido o por vencer, al renovar se añaden otros 3 días al plazo de entrega
        var baseDate = loan.DueDate < today ? today : loan.DueDate;
        loan.DueDate = baseDate.AddDays(RenewalAdditionalDays);
        loan.DateUpdate = now;

        await db.SaveChangesAsync();
        return (MapLoanToDto(loan, today), null, false);
    }

    private static CirculationLoanDto MapLoanToDto(Loan loan, DateOnly today)
    {
        var folio = BookService.NormalizeFolio(loan.Book?.Folio);
        var bookTitle = loan.Book?.Title ?? "Ejemplar bibliográfico";
        var bookSubtitle = !string.IsNullOrWhiteSpace(loan.Book?.Author)
            ? $"{loan.Book!.Author} • {loan.Book.Note ?? "Acervo TecNM"}"
            : loan.Book?.Note ?? "Acervo TecNM Monclova";

        var borrowerName = loan.Borrower?.Name ?? "Estudiante TecNM";
        var controlNumber = loan.Borrower?.InstitutionalId
                            ?? loan.Borrower?.StudentId
                            ?? loan.Borrower?.EmployeeId
                            ?? "21280000";
        var borrowerType = loan.Borrower?.BorrowerType ?? "Alumno";
        var major = loan.Borrower?.Major ?? "Ing. en Sistemas";
        var careerKey = ResolveCareerKey(major);

        var isReturned = loan.ReturnDate.HasValue;
        var isOverdue = !isReturned && loan.DueDate < today;
        var isDueToday = !isReturned && !isOverdue && loan.DueDate == today;
        var daysDiff = loan.DueDate.DayNumber - today.DayNumber;
        var daysOverdue = isOverdue ? Math.Max(1, today.DayNumber - loan.DueDate.DayNumber) : 0;

        string state;
        string statusText;
        bool hasEnrollmentBlock = false;
        string? enrollmentBlockReason = null;

        if (isReturned)
        {
            state = "devuelto";
            statusText = "Devuelto • Sin bloqueo de inscripción";
        }
        else if (isOverdue)
        {
            state = "vencido";
            hasEnrollmentBlock = true;
            statusText = $"Vencido (-{daysOverdue} {(daysOverdue == 1 ? "día" : "días")}) • Bloqueo de Inscripción";
            enrollmentBlockReason = $"Bloqueo de inscripción activo por retraso de {daysOverdue} {(daysOverdue == 1 ? "día" : "días")} en entrega del folio {folio}.";
        }
        else if (isDueToday)
        {
            state = "vence_hoy";
            statusText = "Vence Hoy (Plazo 3 días)";
        }
        else
        {
            state = "en_tiempo";
            var remaining = Math.Max(1, daysDiff);
            statusText = $"En tiempo ({remaining} {(remaining == 1 ? "día" : "días")})";
        }

        var careerDisplay = hasEnrollmentBlock
            ? $"{major} • BLOQUEO DE INSCRIPCIÓN"
            : major;

        return new CirculationLoanDto(
            Id: loan.Id,
            Folio: folio,
            BookId: loan.BookId,
            BookTitle: bookTitle,
            BookFullTitle: bookTitle,
            BookSubtitle: bookSubtitle,
            BorrowerId: loan.BorrowerId,
            StudentName: borrowerName,
            ControlNumber: controlNumber,
            BorrowerType: borrowerType,
            CareerKey: careerKey,
            CareerLabel: careerDisplay,
            LoanDate: FormatSpanishDate(loan.StartDate),
            DueDate: isDueToday ? $"{FormatSpanishDate(loan.DueDate)} (Hoy)" : FormatSpanishDate(loan.DueDate),
            ReturnDate: loan.ReturnDate.HasValue ? FormatSpanishDate(loan.ReturnDate.Value) : null,
            State: state,
            StatusText: statusText,
            IsOverdue: isOverdue,
            IsDueToday: isDueToday,
            HasEnrollmentBlock: hasEnrollmentBlock,
            EnrollmentBlockReason: enrollmentBlockReason,
            DaysOverdue: daysOverdue
        );
    }

    private static string ResolveCareerKey(string major)
    {
        var norm = BookService.NormalizeSearchText(major);
        if (norm.Contains("industrial")) return "industrial";
        if (norm.Contains("mecatronica")) return "mecatronica";
        if (norm.Contains("mecanica")) return "mecanica";
        if (norm.Contains("gestion")) return "gestion";
        if (norm.Contains("renovable") || norm.Contains("energia")) return "energias";
        if (norm.Contains("electronica")) return "electronica";
        return "sistemas";
    }

    private static string FormatSpanishDate(DateOnly date)
    {
        string[] months = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"];
        var month = months[date.Month - 1];
        return $"{date.Day:D2}/{month}/{date.Year % 100:D2}";
    }
}
