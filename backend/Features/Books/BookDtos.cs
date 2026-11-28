namespace TecNM.Api.Features.Books;

public record BookDto(
    int Id,
    string Title,
    string? Note,
    string? Author,
    string Folio,
    string Dewey,
    string Cutter,
    int StatusId,
    string StatusName,
    int ShelfId,
    string ShelfName,
    string AvailableText,
    int AvailabilityPercent,
    IReadOnlyList<string> Topics
);

public record BookMetricsDto(
    int TotalBooks,
    int AvailableCount,
    int BorrowedCount,
    int RepairCount,
    int DiscardCount,
    int CatalogCount
);

public record NextFolioDto(
    string NextFolio,
    int NumericFolio
);

public record BookSearchQuery(
    string? Search = null,
    string? Field = "all",
    string? Status = "all",
    string? SortBy = "dewey"
);

public record CreateBookRequest(
    string Title,
    string? Author,
    string? Note,
    string? Folio,
    string Dewey,
    string Cutter,
    int StatusId,
    int ShelfId,
    string? ShelfName = null,
    IReadOnlyList<string>? Topics = null
);

public record UpdateBookRequest(
    string Title,
    string? Author,
    string? Note,
    string? Folio,
    string Dewey,
    string Cutter,
    int StatusId,
    string? ShelfName = null,
    IReadOnlyList<string>? Topics = null
);

public record UpdateBookStatusRequest(
    int StatusId,
    string? Note
);

public record CreateShelfRequest(string Name);
public record CreateTopicRequest(string Name);

public record ShelfDto(int Id, string Name);
public record TopicDto(int Id, string Name);
public record BookStatusDto(int Id, string Name);
