/* Представления (пункт 3 лабораторной работы) */
USE Kindergarten;
GO

/* VIEW 1. vw_FeeCalculations - расчёт родительской платы
   (4 таблицы + вычисляемые поля: в 3НФ суммы не хранятся) */
DROP VIEW IF EXISTS dbo.vw_FeeCalculations;
GO
CREATE VIEW dbo.vw_FeeCalculations
AS
SELECT
    f.FeeCalculationId,
    f.ChildId,
    c.FullName            AS ChildFullName,
    g.Name                AS GroupName,
    ac.Name               AS AgeCategory,
    bc.Name               AS BenefitCategory,
    f.ChargeYear,
    f.ChargeMonth,
    f.AttendedDays,
    ac.DailyMealCost,
    bc.DiscountPercent,
    CAST(f.AttendedDays * ac.DailyMealCost AS DECIMAL(18,2))                  AS CalculatedAmount,
    CAST(f.AttendedDays * ac.DailyMealCost * bc.DiscountPercent / 100.0
         AS DECIMAL(18,2))                                                     AS BenefitAmount,
    CAST(f.AttendedDays * ac.DailyMealCost * (1 - bc.DiscountPercent / 100.0)
         AS DECIMAL(18,2))                                                     AS TotalToPay,
    f.PaidAmount,
    CAST(f.AttendedDays * ac.DailyMealCost * (1 - bc.DiscountPercent / 100.0)
         - f.PaidAmount AS DECIMAL(18,2))                                      AS Debt,
    f.PaymentDate
FROM dbo.FeeCalculations   f
JOIN dbo.Children          c  ON c.ChildId            = f.ChildId
JOIN dbo.Groups            g  ON g.GroupId            = c.GroupId
JOIN dbo.AgeCategories     ac ON ac.AgeCategoryId     = g.AgeCategoryId
JOIN dbo.BenefitCategories bc ON bc.BenefitCategoryId = c.BenefitCategoryId;
GO

/* VIEW 2. vw_GroupAttendance - табель посещаемости группы
   (LEFT JOIN для причины отсутствия, так как она может быть NULL) */
DROP VIEW IF EXISTS dbo.vw_GroupAttendance;
GO
CREATE VIEW dbo.vw_GroupAttendance
AS
SELECT
    a.AttendanceId,
    g.GroupId,
    g.Name           AS GroupName,
    c.ChildId,
    c.FullName       AS ChildFullName,
    a.AttendanceDate,
    a.IsPresent,
    CASE a.IsPresent
        WHEN 1 THEN N'Присутствовал'
        ELSE N'Отсутствовал'
    END              AS StatusText,
    ar.Name          AS AbsenceReason
FROM dbo.Attendance          a
JOIN dbo.Children            c  ON c.ChildId          = a.ChildId
JOIN dbo.Groups              g  ON g.GroupId          = c.GroupId
LEFT JOIN dbo.AbsenceReasons ar ON ar.AbsenceReasonId = a.AbsenceReasonId;
GO

/* VIEW 3. vw_GroupEnrollment - отчёт о комплектовании групп
   (GROUP BY + вычисление свободных мест) */
DROP VIEW IF EXISTS dbo.vw_GroupEnrollment;
GO
CREATE VIEW dbo.vw_GroupEnrollment
AS
SELECT
    g.GroupId,
    g.Name           AS GroupName,
    ac.AgeCategoryId,
    ac.Name          AS AgeCategory,
    g.Capacity,
    COUNT(c.ChildId) AS Enrolled,
    g.Capacity - COUNT(c.ChildId) AS FreePlaces
FROM dbo.Groups        g
JOIN dbo.AgeCategories ac ON ac.AgeCategoryId = g.AgeCategoryId
LEFT JOIN dbo.Children c  ON c.GroupId        = g.GroupId
GROUP BY g.GroupId, g.Name, ac.AgeCategoryId, ac.Name, g.Capacity;
GO
