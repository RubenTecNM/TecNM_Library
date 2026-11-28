namespace TecNM.Api.Features.Circulation;

public record CirculationLoanDto(
    int Id,
    string Folio,
    int BookId,
    string BookTitle,
    string BookFullTitle,
    string BookSubtitle,
    int BorrowerId,
    string StudentName,
    string ControlNumber,
    string BorrowerType,
    string CareerKey,
    string CareerLabel,
    string LoanDate,
    string DueDate,
    string? ReturnDate,
    string State,
    string StatusText,
    bool IsOverdue,
    bool IsDueToday,
    bool HasEnrollmentBlock,
    string? EnrollmentBlockReason,
    int DaysOverdue
);

public record BlockedStudentAlertDto(
    int LoanId,
    int BorrowerId,
    string StudentName,
    string ControlNumber,
    string CareerLabel,
    string Folio,
    string BookTitle,
    string DueDate,
    int DaysOverdue,
    string BlockReason
);

public record TodayReturnDto(
    int Id,
    string Folio,
    string BookTitle,
    string Time,
    string StudentInfo,
    string Detail,
    bool WasBlocked
);

public record CirculationSummaryDto(
    int ActiveLoans,
    int ScheduledToday,
    int OverdueLoans,
    int BlockedStudentsCount,
    int WebRenewals,
    int ReceivedToday,
    int HistoryCount,
    IReadOnlyList<CirculationLoanDto> Loans,
    IReadOnlyList<BlockedStudentAlertDto> BlockedStudents,
    IReadOnlyList<TodayReturnDto> TodayReturns
);

public record CreateLoanRequest(
    string Folio,
    string? BookTitle,
    string StudentName,
    string ControlNumber,
    string CareerKey,
    string? BorrowerType = "Alumno"
);
