IF DB_ID(N'Kindergarten') IS NOT NULL
    DROP DATABASE Kindergarten;
GO
CREATE DATABASE Kindergarten;
GO
USE Kindergarten;
GO

/* Удаление ранее созданных объектов (повторный запуск скрипта безопасен) */
DROP VIEW      IF EXISTS dbo.vw_FeeCalculations;
DROP VIEW      IF EXISTS dbo.vw_GroupAttendance;
DROP VIEW      IF EXISTS dbo.vw_GroupEnrollment;
DROP PROCEDURE IF EXISTS dbo.usp_AddChild;
DROP PROCEDURE IF EXISTS dbo.usp_UpsertAttendance;
DROP PROCEDURE IF EXISTS dbo.usp_RegisterPayment;
DROP TABLE IF EXISTS dbo.MenuDishLinks;
DROP TABLE IF EXISTS dbo.DailyMenus;
DROP TABLE IF EXISTS dbo.FeeCalculations;
DROP TABLE IF EXISTS dbo.Attendance;
DROP TABLE IF EXISTS dbo.ChildParentLinks;
DROP TABLE IF EXISTS dbo.Educators;
DROP TABLE IF EXISTS dbo.Children;
DROP TABLE IF EXISTS dbo.Groups;
DROP TABLE IF EXISTS dbo.Parents;
DROP TABLE IF EXISTS dbo.Dishes;
DROP TABLE IF EXISTS dbo.MealTypes;
DROP TABLE IF EXISTS dbo.AbsenceReasons;
DROP TABLE IF EXISTS dbo.BenefitCategories;
DROP TABLE IF EXISTS dbo.AgeCategories;
GO

/* 1. AgeCategories - Возрастные категории */
CREATE TABLE dbo.AgeCategories
(
    AgeCategoryId INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Name          NVARCHAR(100) NOT NULL UNIQUE,
    DailyMealCost DECIMAL(18,2) NOT NULL CHECK (DailyMealCost >= 0)
);
GO

/* 2. BenefitCategories - Категории льгот */
CREATE TABLE dbo.BenefitCategories
(
    BenefitCategoryId INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Name              NVARCHAR(100) NOT NULL UNIQUE,
    DiscountPercent   DECIMAL(5,2)  NOT NULL CHECK (DiscountPercent BETWEEN 0 AND 100)
);
GO

/* 3. AbsenceReasons - Причины отсутствия */
CREATE TABLE dbo.AbsenceReasons
(
    AbsenceReasonId INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Name            NVARCHAR(200) NOT NULL UNIQUE
);
GO

/* 4. MealTypes - Типы приёмов пищи */
CREATE TABLE dbo.MealTypes
(
    MealTypeId INT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Name       NVARCHAR(50) NOT NULL UNIQUE
);
GO

/* 5. Dishes - Блюда */
CREATE TABLE dbo.Dishes
(
    DishId INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Name   NVARCHAR(150) NOT NULL UNIQUE
);
GO

/* 6. Parents - Родители */
CREATE TABLE dbo.Parents
(
    ParentId  INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    FullName  NVARCHAR(150) NOT NULL,
    Address   NVARCHAR(250) NULL,
    Phone     NVARCHAR(20)  NULL,
    Workplace NVARCHAR(200) NULL
);
GO

/* 7. Groups - Группы */
CREATE TABLE dbo.Groups
(
    GroupId       INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Name          NVARCHAR(100) NOT NULL UNIQUE,
    AgeCategoryId INT           NOT NULL REFERENCES dbo.AgeCategories(AgeCategoryId),
    Capacity      INT           NOT NULL CHECK (Capacity > 0)
);
GO

/* 8. Children - Воспитанники */
CREATE TABLE dbo.Children
(
    ChildId           INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    FullName          NVARCHAR(150) NOT NULL,
    BirthDate         DATE          NOT NULL,
    GroupId           INT           NULL REFERENCES dbo.Groups(GroupId) ON DELETE SET NULL,
    EnrollmentDate    DATE          NOT NULL,
    BenefitCategoryId INT           NOT NULL REFERENCES dbo.BenefitCategories(BenefitCategoryId),
    CHECK (EnrollmentDate >= BirthDate)
);
GO

/* 9. ChildParentLinks - Связь ребёнок - родитель (M:N) */
CREATE TABLE dbo.ChildParentLinks
(
    ChildId      INT          NOT NULL REFERENCES dbo.Children(ChildId) ON DELETE CASCADE,
    ParentId     INT          NOT NULL REFERENCES dbo.Parents(ParentId) ON DELETE CASCADE,
    RelationType NVARCHAR(50) NOT NULL,
    PRIMARY KEY (ChildId, ParentId),
    CHECK (RelationType IN (N'Мать', N'Отец', N'Опекун', N'Отчим', N'Мачеха'))
);
GO

/* 10. Educators - Воспитатели */
CREATE TABLE dbo.Educators
(
    EducatorId   INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    FullName     NVARCHAR(150) NOT NULL,
    Education    NVARCHAR(150) NOT NULL,
    WorkSchedule NVARCHAR(100) NOT NULL,
    GroupId      INT           NOT NULL REFERENCES dbo.Groups(GroupId)
);
GO

/* 11. Attendance - Табель посещаемости */
CREATE TABLE dbo.Attendance
(
    AttendanceId    BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    ChildId         INT    NOT NULL REFERENCES dbo.Children(ChildId) ON DELETE CASCADE,
    AttendanceDate  DATE   NOT NULL,
    IsPresent       BIT    NOT NULL,
    AbsenceReasonId INT    NULL REFERENCES dbo.AbsenceReasons(AbsenceReasonId),
    UNIQUE (ChildId, AttendanceDate),
    CHECK (
        (IsPresent = 1 AND AbsenceReasonId IS NULL)
        OR
        (IsPresent = 0 AND AbsenceReasonId IS NOT NULL)
    )
);
GO

/* 12. DailyMenus - Дневное меню */
CREATE TABLE dbo.DailyMenus
(
    DailyMenuId   BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    MenuDate      DATE   NOT NULL,
    AgeCategoryId INT    NOT NULL REFERENCES dbo.AgeCategories(AgeCategoryId),
    MealTypeId    INT    NOT NULL REFERENCES dbo.MealTypes(MealTypeId),
    UNIQUE (MenuDate, AgeCategoryId, MealTypeId)
);
GO

/* 13. MenuDishLinks - Состав блюд в меню (M:N) */
CREATE TABLE dbo.MenuDishLinks
(
    DailyMenuId BIGINT NOT NULL REFERENCES dbo.DailyMenus(DailyMenuId) ON DELETE CASCADE,
    DishId      INT    NOT NULL REFERENCES dbo.Dishes(DishId) ON DELETE CASCADE,
    PRIMARY KEY (DailyMenuId, DishId)
);
GO

/* 14. FeeCalculations - Начисление родительской платы (без вычисляемых полей) */
CREATE TABLE dbo.FeeCalculations
(
    FeeCalculationId BIGINT        NOT NULL IDENTITY(1,1) PRIMARY KEY,
    ChildId          INT           NOT NULL REFERENCES dbo.Children(ChildId) ON DELETE CASCADE,
    ChargeYear       INT           NOT NULL CHECK (ChargeYear BETWEEN 2000 AND 2100),
    ChargeMonth      INT           NOT NULL CHECK (ChargeMonth BETWEEN 1 AND 12),
    AttendedDays     INT           NOT NULL CHECK (AttendedDays BETWEEN 0 AND 31),
    PaidAmount       DECIMAL(18,2) NOT NULL DEFAULT (0) CHECK (PaidAmount >= 0),
    PaymentDate      DATE          NULL,
    UNIQUE (ChildId, ChargeYear, ChargeMonth)
);
GO

/* 15. Индексы */
CREATE INDEX IX_Attendance_Child_Date  ON dbo.Attendance(ChildId, AttendanceDate);
CREATE INDEX IX_Children_GroupId       ON dbo.Children(GroupId);
CREATE INDEX IX_FeeCalculations_Period ON dbo.FeeCalculations(ChargeYear, ChargeMonth);
CREATE INDEX IX_DailyMenus_Date        ON dbo.DailyMenus(MenuDate);
GO
