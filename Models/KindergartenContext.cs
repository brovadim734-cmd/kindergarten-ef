using System;
using System.Collections.Generic;
using Microsoft.Extensions.Configuration;
using Microsoft.EntityFrameworkCore;

namespace KindergartenEf.Models;

public partial class KindergartenContext : DbContext
{
    public KindergartenContext()
    {
    }

    public KindergartenContext(DbContextOptions<KindergartenContext> options)
        : base(options)
    {
    }

    public virtual DbSet<AbsenceReason> AbsenceReasons { get; set; }

    public virtual DbSet<AgeCategory> AgeCategories { get; set; }

    public virtual DbSet<Attendance> Attendances { get; set; }

    public virtual DbSet<BenefitCategory> BenefitCategories { get; set; }

    public virtual DbSet<Child> Children { get; set; }

    public virtual DbSet<ChildParentLink> ChildParentLinks { get; set; }

    public virtual DbSet<DailyMenu> DailyMenus { get; set; }

    public virtual DbSet<Dish> Dishes { get; set; }

    public virtual DbSet<Educator> Educators { get; set; }

    public virtual DbSet<FeeCalculation> FeeCalculations { get; set; }

    public virtual DbSet<Group> Groups { get; set; }

    public virtual DbSet<MealType> MealTypes { get; set; }

    public virtual DbSet<Parent> Parents { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!optionsBuilder.IsConfigured)
        {
            var config = new ConfigurationBuilder()
                .SetBasePath(AppContext.BaseDirectory)
                .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
                .Build();

            var cs = config.GetConnectionString("KindergartenDb");
            optionsBuilder.UseSqlServer(cs);
        }
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<AbsenceReason>(entity =>
        {
            entity.HasKey(e => e.AbsenceReasonId).HasName("PK__AbsenceR__FD4C44919940F2FC");

            entity.HasIndex(e => e.Name, "UQ__AbsenceR__737584F614CF25D0").IsUnique();

            entity.Property(e => e.Name).HasMaxLength(200);
        });

        modelBuilder.Entity<AgeCategory>(entity =>
        {
            entity.HasKey(e => e.AgeCategoryId).HasName("PK__AgeCateg__9E07484B3B090ED7");

            entity.HasIndex(e => e.Name, "UQ__AgeCateg__737584F66BE3EB29").IsUnique();

            entity.Property(e => e.DailyMealCost).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.Name).HasMaxLength(100);
        });

        modelBuilder.Entity<Attendance>(entity =>
        {
            entity.HasKey(e => e.AttendanceId).HasName("PK__Attendan__8B69261CBE463108");

            entity.ToTable("Attendance");

            entity.HasIndex(e => new { e.ChildId, e.AttendanceDate }, "IX_Attendance_Child_Date");

            entity.HasIndex(e => new { e.ChildId, e.AttendanceDate }, "UQ__Attendan__B380FF6847E5C549").IsUnique();

            entity.HasOne(d => d.AbsenceReason).WithMany(p => p.Attendances)
                .HasForeignKey(d => d.AbsenceReasonId)
                .HasConstraintName("FK__Attendanc__Absen__6FE99F9F");

            entity.HasOne(d => d.Child).WithMany(p => p.Attendances)
                .HasForeignKey(d => d.ChildId)
                .HasConstraintName("FK__Attendanc__Child__6EF57B66");
        });

        modelBuilder.Entity<BenefitCategory>(entity =>
        {
            entity.HasKey(e => e.BenefitCategoryId).HasName("PK__BenefitC__B4D8750BEB4E1A95");

            entity.HasIndex(e => e.Name, "UQ__BenefitC__737584F67AEBC52B").IsUnique();

            entity.Property(e => e.DiscountPercent).HasColumnType("decimal(5, 2)");
            entity.Property(e => e.Name).HasMaxLength(100);
        });

        modelBuilder.Entity<Child>(entity =>
        {
            entity.HasKey(e => e.ChildId).HasName("PK__Children__BEFA071600EE69B9");

            entity.HasIndex(e => e.GroupId, "IX_Children_GroupId");

            entity.Property(e => e.FullName).HasMaxLength(150);

            entity.HasOne(d => d.BenefitCategory).WithMany(p => p.Children)
                .HasForeignKey(d => d.BenefitCategoryId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Children__Benefi__628FA481");

            entity.HasOne(d => d.Group).WithMany(p => p.Children)
                .HasForeignKey(d => d.GroupId)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("FK__Children__GroupI__619B8048");
        });

        modelBuilder.Entity<ChildParentLink>(entity =>
        {
            entity.HasKey(e => new { e.ChildId, e.ParentId }).HasName("PK__ChildPar__53C992007B7462C7");

            entity.Property(e => e.RelationType).HasMaxLength(50);

            entity.HasOne(d => d.Child).WithMany(p => p.ChildParentLinks)
                .HasForeignKey(d => d.ChildId)
                .HasConstraintName("FK__ChildPare__Child__66603565");

            entity.HasOne(d => d.Parent).WithMany(p => p.ChildParentLinks)
                .HasForeignKey(d => d.ParentId)
                .HasConstraintName("FK__ChildPare__Paren__6754599E");
        });

        modelBuilder.Entity<DailyMenu>(entity =>
        {
            entity.HasKey(e => e.DailyMenuId).HasName("PK__DailyMen__9A5CB7858BAD925E");

            entity.HasIndex(e => e.MenuDate, "IX_DailyMenus_Date");

            entity.HasIndex(e => new { e.MenuDate, e.AgeCategoryId, e.MealTypeId }, "UQ__DailyMen__8B12C87098F4731A").IsUnique();

            entity.HasOne(d => d.AgeCategory).WithMany(p => p.DailyMenus)
                .HasForeignKey(d => d.AgeCategoryId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__DailyMenu__AgeCa__74AE54BC");

            entity.HasOne(d => d.MealType).WithMany(p => p.DailyMenus)
                .HasForeignKey(d => d.MealTypeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__DailyMenu__MealT__75A278F5");

            entity.HasMany(d => d.Dishes).WithMany(p => p.DailyMenus)
                .UsingEntity<Dictionary<string, object>>(
                    "MenuDishLink",
                    r => r.HasOne<Dish>().WithMany()
                        .HasForeignKey("DishId")
                        .HasConstraintName("FK__MenuDishL__DishI__797309D9"),
                    l => l.HasOne<DailyMenu>().WithMany()
                        .HasForeignKey("DailyMenuId")
                        .HasConstraintName("FK__MenuDishL__Daily__787EE5A0"),
                    j =>
                    {
                        j.HasKey("DailyMenuId", "DishId").HasName("PK__MenuDish__8BD483703859D9AC");
                        j.ToTable("MenuDishLinks");
                    });
        });

        modelBuilder.Entity<Dish>(entity =>
        {
            entity.HasKey(e => e.DishId).HasName("PK__Dishes__18834F50F36B603C");

            entity.HasIndex(e => e.Name, "UQ__Dishes__737584F684E41285").IsUnique();

            entity.Property(e => e.Name).HasMaxLength(150);
        });

        modelBuilder.Entity<Educator>(entity =>
        {
            entity.HasKey(e => e.EducatorId).HasName("PK__Educator__1F85B33B564B59C5");

            entity.Property(e => e.Education).HasMaxLength(150);
            entity.Property(e => e.FullName).HasMaxLength(150);
            entity.Property(e => e.WorkSchedule).HasMaxLength(100);

            entity.HasOne(d => d.Group).WithMany(p => p.Educators)
                .HasForeignKey(d => d.GroupId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Educators__Group__6B24EA82");
        });

        modelBuilder.Entity<FeeCalculation>(entity =>
        {
            entity.HasKey(e => e.FeeCalculationId).HasName("PK__FeeCalcu__127BD2C73E532744");

            entity.HasIndex(e => new { e.ChargeYear, e.ChargeMonth }, "IX_FeeCalculations_Period");

            entity.HasIndex(e => new { e.ChildId, e.ChargeYear, e.ChargeMonth }, "UQ__FeeCalcu__D0A1486433CFB4A1").IsUnique();

            entity.Property(e => e.PaidAmount).HasColumnType("decimal(18, 2)");

            entity.HasOne(d => d.Child).WithMany(p => p.FeeCalculations)
                .HasForeignKey(d => d.ChildId)
                .HasConstraintName("FK__FeeCalcul__Child__7D439ABD");
        });

        modelBuilder.Entity<Group>(entity =>
        {
            entity.HasKey(e => e.GroupId).HasName("PK__Groups__149AF36A2A149646");

            entity.HasIndex(e => e.Name, "UQ__Groups__737584F67A8BFFF2").IsUnique();

            entity.Property(e => e.Name).HasMaxLength(100);

            entity.HasOne(d => d.AgeCategory).WithMany(p => p.Groups)
                .HasForeignKey(d => d.AgeCategoryId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Groups__AgeCateg__5DCAEF64");
        });

        modelBuilder.Entity<MealType>(entity =>
        {
            entity.HasKey(e => e.MealTypeId).HasName("PK__MealType__702B379E4E319D19");

            entity.HasIndex(e => e.Name, "UQ__MealType__737584F67D08A16F").IsUnique();

            entity.Property(e => e.Name).HasMaxLength(50);
        });

        modelBuilder.Entity<Parent>(entity =>
        {
            entity.HasKey(e => e.ParentId).HasName("PK__Parents__D339516FB00DF036");

            entity.Property(e => e.Address).HasMaxLength(250);
            entity.Property(e => e.FullName).HasMaxLength(150);
            entity.Property(e => e.Phone).HasMaxLength(20);
            entity.Property(e => e.Workplace).HasMaxLength(200);
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
