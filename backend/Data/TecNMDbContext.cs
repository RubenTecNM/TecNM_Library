using Microsoft.EntityFrameworkCore;
using TecNM.Api.Core.Entities;

namespace TecNM.Api.Data;

public sealed class TecNMDbContext(DbContextOptions<TecNMDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        var user = modelBuilder.Entity<User>();

        user.ToTable("users", table =>
            table.HasCheckConstraint("ck_users_role", "role IN ('Admin', 'User')"));
        user.HasKey(item => item.Id).HasName("pk_users");
        user.HasIndex(item => item.Username).IsUnique().HasDatabaseName("uq_users_username");
        user.HasIndex(item => item.Email).IsUnique().HasDatabaseName("uq_users_email");

        user.Property(item => item.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
        user.Property(item => item.Username).HasColumnName("username").HasMaxLength(64).IsRequired();
        user.Property(item => item.Email).HasColumnName("email").HasMaxLength(254).IsRequired();
        user.Property(item => item.Password).HasColumnName("password").HasMaxLength(512).IsRequired();
        user.Property(item => item.Name).HasColumnName("name").HasMaxLength(160).IsRequired();
        user.Property(item => item.Role).HasColumnName("role").HasMaxLength(16).IsRequired();
        user.Property(item => item.IsActive).HasColumnName("is_active").IsRequired();
        user.Property(item => item.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("CURRENT_TIMESTAMP")
            .IsRequired();
    }
}
