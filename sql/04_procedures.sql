/* Хранимые процедуры (пункт 4 лабораторной работы).
   Префикс usp_ (user stored procedure) вместо sp_ : префикс sp_ зарезервирован
   для системных процедур, SQL Server сначала ищет такие имена в базе master. */
USE Kindergarten;
GO

/* PROC 1. usp_AddChild - добавление воспитанника */
DROP PROCEDURE IF EXISTS dbo.usp_AddChild;
GO
CREATE PROCEDURE dbo.usp_AddChild
    @FullName          NVARCHAR(150),
    @BirthDate         DATE,
    @GroupId           INT = NULL,
    @EnrollmentDate    DATE,
    @BenefitCategoryId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @EnrollmentDate < @BirthDate
    BEGIN
        RAISERROR(N'Дата зачисления не может быть раньше даты рождения.', 16, 1);
        RETURN;
    END

    IF @GroupId IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM dbo.Groups WHERE GroupId = @GroupId)
    BEGIN
        RAISERROR(N'Указанная группа не существует.', 16, 1);
        RETURN;
    END

    IF @GroupId IS NOT NULL
       AND (SELECT COUNT(*) FROM dbo.Children WHERE GroupId = @GroupId)
           >= (SELECT Capacity FROM dbo.Groups WHERE GroupId = @GroupId)
    BEGIN
        RAISERROR(N'В указанной группе нет свободных мест.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.BenefitCategories
                   WHERE BenefitCategoryId = @BenefitCategoryId)
    BEGIN
        RAISERROR(N'Указанная категория льгот не существует.', 16, 1);
        RETURN;
    END

    INSERT INTO dbo.Children
        (FullName, BirthDate, GroupId, EnrollmentDate, BenefitCategoryId)
    VALUES
        (@FullName, @BirthDate, @GroupId, @EnrollmentDate, @BenefitCategoryId);

    PRINT N'Воспитанник успешно добавлен. ChildId = '
        + CAST(SCOPE_IDENTITY() AS NVARCHAR(20));
END;
GO

/* PROC 2. usp_UpsertAttendance - вставка/обновление отметки посещаемости */
DROP PROCEDURE IF EXISTS dbo.usp_UpsertAttendance;
GO
CREATE PROCEDURE dbo.usp_UpsertAttendance
    @ChildId         INT,
    @AttendanceDate  DATE,
    @IsPresent       BIT,
    @AbsenceReasonId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Children WHERE ChildId = @ChildId)
    BEGIN
        RAISERROR(N'Воспитанник с указанным ChildId не существует.', 16, 1);
        RETURN;
    END

    IF @IsPresent = 0 AND @AbsenceReasonId IS NULL
    BEGIN
        RAISERROR(N'При отсутствии необходимо указать причину.', 16, 1);
        RETURN;
    END

    IF @IsPresent = 1 AND @AbsenceReasonId IS NOT NULL
    BEGIN
        RAISERROR(N'При присутствии причина отсутствия не указывается.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM dbo.Attendance
               WHERE ChildId = @ChildId AND AttendanceDate = @AttendanceDate)
    BEGIN
        UPDATE dbo.Attendance
        SET IsPresent       = @IsPresent,
            AbsenceReasonId = @AbsenceReasonId
        WHERE ChildId = @ChildId AND AttendanceDate = @AttendanceDate;

        PRINT N'Запись посещаемости обновлена.';
    END
    ELSE
    BEGIN
        INSERT INTO dbo.Attendance
            (ChildId, AttendanceDate, IsPresent, AbsenceReasonId)
        VALUES
            (@ChildId, @AttendanceDate, @IsPresent, @AbsenceReasonId);

        PRINT N'Запись посещаемости добавлена.';
    END
END;
GO

/* PROC 3. usp_RegisterPayment - регистрация оплаты */
DROP PROCEDURE IF EXISTS dbo.usp_RegisterPayment;
GO
CREATE PROCEDURE dbo.usp_RegisterPayment
    @ChildId      INT,
    @ChargeYear   INT,
    @ChargeMonth  INT,
    @PaidAmount   DECIMAL(18,2),
    @PaymentDate  DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @PaidAmount <= 0
    BEGIN
        RAISERROR(N'Сумма оплаты должна быть положительной.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.FeeCalculations
                   WHERE ChildId = @ChildId
                     AND ChargeYear = @ChargeYear
                     AND ChargeMonth = @ChargeMonth)
    BEGIN
        RAISERROR(N'Расчёт за указанный период не найден.', 16, 1);
        RETURN;
    END

    UPDATE dbo.FeeCalculations
    SET PaidAmount  = PaidAmount + @PaidAmount,
        PaymentDate = @PaymentDate
    WHERE ChildId = @ChildId
      AND ChargeYear = @ChargeYear
      AND ChargeMonth = @ChargeMonth;

    PRINT N'Оплата зарегистрирована. Сумма: '
        + CAST(@PaidAmount AS NVARCHAR(20)) + N' руб.';
END;
GO
