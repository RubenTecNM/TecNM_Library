using System.Collections;
using Microsoft.EntityFrameworkCore;
using TecNM.Api.Features.Books;

namespace TecNM.Api.Data;

public sealed class TecNMDbContext(DbContextOptions<TecNMDbContext> options) : DbContext(options)
{
    public DbSet<Book> Books => Set<Book>();
    public DbSet<BookStatus> BookStatuses => Set<BookStatus>();
    public DbSet<Shelf> Shelves => Set<Shelf>();
    public DbSet<Author> Authors => Set<Author>();
    public DbSet<Topic> Topics => Set<Topic>();
    public DbSet<Role> Roles => Set<Role>();
    public DbSet<Borrower> Borrowers => Set<Borrower>();
    public DbSet<Loan> Loans => Set<Loan>();
    public DbSet<BookAuthor> BookAuthors => Set<BookAuthor>();
    public DbSet<BookTopic> BookTopics => Set<BookTopic>();
    public DbSet<Service> Services => Set<Service>();
    public DbSet<Visit> Visits => Set<Visit>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // BookStatus
        modelBuilder.Entity<BookStatus>(entity =>
        {
            entity.ToTable("bookstatus");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Name).HasColumnName("name").HasMaxLength(50).IsRequired();
            ConfigureAuditFields(entity);
        });

        // Shelf
        modelBuilder.Entity<Shelf>(entity =>
        {
            entity.ToTable("shelf");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Name).HasColumnName("name").HasMaxLength(100).IsRequired();
            ConfigureAuditFields(entity);
        });

        // Author
        modelBuilder.Entity<Author>(entity =>
        {
            entity.ToTable("author");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Name).HasColumnName("name").HasMaxLength(100).IsRequired();
            entity.Property(e => e.LastName).HasColumnName("lastname").HasMaxLength(100).IsRequired();
            ConfigureAuditFields(entity);
        });

        // Topic
        modelBuilder.Entity<Topic>(entity =>
        {
            entity.ToTable("topic");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Name).HasColumnName("name").HasMaxLength(100).IsRequired();
            ConfigureAuditFields(entity);
        });

        // Role
        modelBuilder.Entity<Role>(entity =>
        {
            entity.ToTable("role");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Name).HasColumnName("name").HasMaxLength(50).IsRequired();
            entity.HasIndex(e => e.Name).IsUnique();
            entity.Property(e => e.Description).HasColumnName("description").HasMaxLength(255);
            ConfigureAuditFields(entity);
        });

        // Borrower
        modelBuilder.Entity<Borrower>(entity =>
        {
            entity.ToTable("borrower");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Name).HasColumnName("name").HasMaxLength(150).IsRequired();
            entity.Property(e => e.StudentId).HasColumnName("studentid").HasMaxLength(30).IsRequired();
            entity.Property(e => e.Major).HasColumnName("major").HasMaxLength(100).IsRequired();
            entity.Property(e => e.Semester).HasColumnName("semester").HasMaxLength(20);
            entity.Property(e => e.Time).HasColumnName("time").HasMaxLength(50).IsRequired();
            entity.Property(e => e.Gender).HasColumnName("gender").HasMaxLength(20).IsRequired();
            entity.Property(e => e.PhoneNumber).HasColumnName("phonenumber").HasMaxLength(25);
            entity.Property(e => e.Email).HasColumnName("email").HasMaxLength(150).IsRequired();
            entity.Property(e => e.RoleId).HasColumnName("role_id").HasDefaultValue(3);

            entity.HasOne(e => e.Role)
                  .WithMany(r => r.Borrowers)
                  .HasForeignKey(e => e.RoleId);

            ConfigureAuditFields(entity);
        });

        // Book
        modelBuilder.Entity<Book>(entity =>
        {
            entity.ToTable("book");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Title).HasColumnName("title").HasMaxLength(255).IsRequired();
            entity.Property(e => e.Note).HasColumnName("note");
            entity.Property(e => e.Author).HasColumnName("author").HasMaxLength(255);
            entity.Property(e => e.Folio).HasColumnName("folio").HasMaxLength(50).IsRequired();
            entity.Property(e => e.Dewey).HasColumnName("dewey").HasMaxLength(50).IsRequired();
            entity.Property(e => e.Cutter).HasColumnName("cutter").HasMaxLength(50).IsRequired();
            entity.Property(e => e.StatusId).HasColumnName("status_id");
            entity.Property(e => e.ShelfId).HasColumnName("shelf_id");

            entity.HasOne(e => e.Status)
                  .WithMany(s => s.Books)
                  .HasForeignKey(e => e.StatusId);

            entity.HasOne(e => e.Shelf)
                  .WithMany(s => s.Books)
                  .HasForeignKey(e => e.ShelfId);

            ConfigureAuditFields(entity);
            entity.HasQueryFilter(e => e.IdStatus);
        });

        // Loan
        modelBuilder.Entity<Loan>(entity =>
        {
            entity.ToTable("loan");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.BookId).HasColumnName("book_id");
            entity.Property(e => e.BorrowerId).HasColumnName("borrower_id");
            entity.Property(e => e.StartDate).HasColumnName("startdate");
            entity.Property(e => e.DueDate).HasColumnName("duedate");
            entity.Property(e => e.ReturnDate).HasColumnName("returndate");
            entity.Property(e => e.Responsible).HasColumnName("responsible").HasMaxLength(150).IsRequired();

            entity.HasOne(e => e.Book)
                  .WithMany(b => b.Loans)
                  .HasForeignKey(e => e.BookId);

            entity.HasOne(e => e.Borrower)
                  .WithMany(b => b.Loans)
                  .HasForeignKey(e => e.BorrowerId);

            ConfigureAuditFields(entity);
            entity.HasQueryFilter(e => e.IdStatus);
        });

        // Book_Author
        modelBuilder.Entity<BookAuthor>(entity =>
        {
            entity.ToTable("book_author");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.BookId).HasColumnName("book_id");
            entity.Property(e => e.AuthorId).HasColumnName("author_id");

            entity.HasOne(e => e.Book)
                  .WithMany(b => b.BookAuthors)
                  .HasForeignKey(e => e.BookId);

            entity.HasOne(e => e.Author)
                  .WithMany(a => a.BookAuthors)
                  .HasForeignKey(e => e.AuthorId);

            ConfigureAuditFields(entity);
        });

        // Book_Topic
        modelBuilder.Entity<BookTopic>(entity =>
        {
            entity.ToTable("book_topic");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.BookId).HasColumnName("book_id");
            entity.Property(e => e.TopicId).HasColumnName("topic_id");

            entity.HasOne(e => e.Book)
                  .WithMany(b => b.BookTopics)
                  .HasForeignKey(e => e.BookId);

            entity.HasOne(e => e.Topic)
                  .WithMany(t => t.BookTopics)
                  .HasForeignKey(e => e.TopicId);

            ConfigureAuditFields(entity);
        });

        // Service
        modelBuilder.Entity<Service>(entity =>
        {
            entity.ToTable("service");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Name).HasColumnName("name").HasMaxLength(100).IsRequired();
            entity.HasIndex(e => e.Name).IsUnique();
            entity.Property(e => e.Description).HasColumnName("description").HasMaxLength(255);
            ConfigureAuditFields(entity);
        });

        // Visit
        modelBuilder.Entity<Visit>(entity =>
        {
            entity.ToTable("visit");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.BorrowerId).HasColumnName("borrower_id");
            entity.Property(e => e.ServiceId).HasColumnName("service_id");
            entity.Property(e => e.EntryDate).HasColumnName("entrydate");
            entity.Property(e => e.ExitDate).HasColumnName("exitdate");
            entity.Property(e => e.Notes).HasColumnName("notes");

            entity.HasOne(e => e.Borrower)
                  .WithMany(b => b.Visits)
                  .HasForeignKey(e => e.BorrowerId);

            entity.HasOne(e => e.Service)
                  .WithMany(s => s.Visits)
                  .HasForeignKey(e => e.ServiceId);

            entity.HasIndex(e => new { e.ServiceId, e.EntryDate }).HasDatabaseName("idx_visit_service_entry");
            entity.HasIndex(e => new { e.BorrowerId, e.EntryDate }).HasDatabaseName("idx_visit_borrower_entry");

            ConfigureAuditFields(entity);
            entity.HasQueryFilter(e => e.IdStatus);
        });
    }

    private static void ConfigureAuditFields<T>(Microsoft.EntityFrameworkCore.Metadata.Builders.EntityTypeBuilder<T> entity) where T : class
    {
        entity.Property<int>("IdUserCreate").HasColumnName("idusercreate");
        entity.Property<DateTime>("DateCreate").HasColumnName("datecreate");
        entity.Property<int?>("IdUserUpdate").HasColumnName("iduserupdate");
        entity.Property<DateTime?>("DateUpdate").HasColumnName("dateupdate");
        entity.Property<int?>("IdUserDelete").HasColumnName("iduserdelete");
        entity.Property<DateTime?>("DateDelete").HasColumnName("datedelete");

        entity.Property<bool>("IdStatus")
              .HasColumnName("idstatus")
              .HasConversion(
                  v => new BitArray(new[] { v }),
                  v => v != null && v.Length > 0 && v[0]);
    }
}
