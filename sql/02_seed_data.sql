/*
   Заполнение БД тестовыми данными (пункт 2.2 лабораторной работы)

   Смоделировано объединение дошкольных учреждений: 25 учреждений, 500 групп.

   Сторона «один» (>= 500 записей):
     Groups (500), Parents (20 000), Children (10 000)
   Сторона «многие» (>= 20 000 записей):
     ChildParentLinks (20 000), Attendance (40 000), FeeCalculations (20 000)
   Справочники предметной области (AgeCategories, BenefitCategories,
   AbsenceReasons, MealTypes, Dishes) содержат реальный для предметной области
   набор значений. Меню, воспитатели - вспомогательные данные.

   Скрипт предназначен для запуска на пустых таблицах (после скрипта создания).
*/
USE Kindergarten;
GO
SET NOCOUNT ON;
GO

/* Вспомогательная таблица чисел 1..20000 */
DROP TABLE IF EXISTS dbo.Numbers;
GO
CREATE TABLE dbo.Numbers (n INT NOT NULL PRIMARY KEY);
GO
;WITH N AS (
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.Numbers (n) SELECT TOP (20000) n FROM N;
GO

/* ЭТАП 1. СПРАВОЧНИКИ */

INSERT INTO dbo.AgeCategories (Name, DailyMealCost) VALUES
    (N'Ясельная (1–2 года)', 3.20),
    (N'Первая младшая (2–3 года)', 3.50),
    (N'Вторая младшая (3–4 года)', 3.80),
    (N'Средняя (4–5 лет)', 4.10),
    (N'Старшая (5–6 лет)', 4.40),
    (N'Подготовительная (6–7 лет)', 4.70);

INSERT INTO dbo.BenefitCategories (Name, DiscountPercent) VALUES
    (N'Без льготы', 0),
    (N'Многодетная семья', 50),
    (N'Ребёнок-инвалид', 100),
    (N'Ребёнок-сирота', 100),
    (N'Малообеспеченная семья', 30),
    (N'Семья работника учреждения', 25);

INSERT INTO dbo.AbsenceReasons (Name) VALUES
    (N'Болезнь ребёнка'),
    (N'Карантин в группе'),
    (N'Отпуск родителей'),
    (N'Семейные обстоятельства'),
    (N'Санаторно-курортное лечение'),
    (N'Неблагоприятные погодные условия'),
    (N'Посещение врача'),
    (N'Без уважительной причины');

INSERT INTO dbo.MealTypes (Name) VALUES
    (N'Завтрак'),
    (N'Второй завтрак'),
    (N'Обед'),
    (N'Полдник'),
    (N'Ужин');

INSERT INTO dbo.Dishes (Name) VALUES
    (N'Каша овсяная молочная'),
    (N'Каша манная молочная'),
    (N'Каша гречневая молочная'),
    (N'Каша рисовая молочная'),
    (N'Омлет паровой'),
    (N'Сырники со сметаной'),
    (N'Бутерброд с маслом и сыром'),
    (N'Какао на молоке'),
    (N'Чай с молоком'),
    (N'Чай с лимоном'),
    (N'Запеканка творожная'),
    (N'Оладьи с джемом'),
    (N'Суп овощной'),
    (N'Борщ со сметаной'),
    (N'Суп куриный с лапшой'),
    (N'Рассольник'),
    (N'Суп гороховый'),
    (N'Суп молочный с вермишелью'),
    (N'Котлета паровая'),
    (N'Тефтели в соусе'),
    (N'Рыба запечённая'),
    (N'Курица отварная'),
    (N'Гуляш из говядины'),
    (N'Печень тушёная'),
    (N'Картофельное пюре'),
    (N'Гречка рассыпчатая'),
    (N'Макароны отварные'),
    (N'Рис отварной'),
    (N'Салат из свежей капусты'),
    (N'Салат из свёклы'),
    (N'Компот из сухофруктов'),
    (N'Кисель ягодный'),
    (N'Кефир'),
    (N'Ряженка'),
    (N'Булочка с изюмом'),
    (N'Печенье'),
    (N'Яблоко свежее'),
    (N'Банан'),
    (N'Йогурт детский'),
    (N'Пирожок с яблоком');
GO

/* ЭТАП 2. ТАБЛИЦЫ СТОРОНЫ «ОДИН» */

/* 2.1. Groups - 500 записей (25 учреждений по 20 групп) */
INSERT INTO dbo.Groups (Name, AgeCategoryId, Capacity)
SELECT N'Д/с №' + CAST(1 + (n - 1) / 20 AS NVARCHAR(5))
       + N', группа «' + CHOOSE(1 + (n - 1) % 20, N'Солнышко', N'Ромашка', N'Колокольчик', N'Василёк', N'Радуга', N'Звёздочка', N'Капелька', N'Подснежник', N'Берёзка', N'Теремок', N'Ладушки', N'Непоседы', N'Улыбка', N'Мишутки', N'Бусинка', N'Росинка', N'Журавушка', N'Синичка', N'Одуванчик', N'Лучик') + N'»',
       1 + (n - 1) % 6,
       22 + n % 4
FROM dbo.Numbers
WHERE n <= 500
ORDER BY n;
GO

/* 2.2. Воспитатели - по одному на группу (500 записей) */
INSERT INTO dbo.Educators (FullName, Education, WorkSchedule, GroupId)
SELECT CHOOSE(1 + n % 20, N'Иванов', N'Петров', N'Сидоров', N'Козлов', N'Новиков', N'Морозов', N'Волков', N'Соколов', N'Лебедев', N'Ковалёв', N'Орлов', N'Зайцев', N'Павлов', N'Семёнов', N'Голубев', N'Виноградов', N'Богданов', N'Воробьёв', N'Фёдоров', N'Михайлов') + N'а '
       + CHOOSE(1 + (n * 3) % 10, N'Анна', N'Мария', N'София', N'Алиса', N'Виктория', N'Полина', N'Дарья', N'Елена', N'Ольга', N'Екатерина') + N' '
       + CHOOSE(1 + (n * 7) % 10, N'Александровна', N'Дмитриевна', N'Максимовна', N'Ивановна', N'Артёмовна', N'Михайловна', N'Никитична', N'Егоровна', N'Андреевна', N'Кирилловна'),
       CHOOSE(1 + n % 3, N'Высшее педагогическое', N'Среднее специальное педагогическое', N'Высшее дошкольное'),
       CHOOSE(1 + n % 2, N'1 смена: 07:00-14:00', N'2 смена: 12:00-19:00'),
       n
FROM dbo.Numbers
WHERE n <= 500
ORDER BY n;
GO

/* 2.3. Children - 10 000 записей.
   Возраст воспитанника соответствует возрастной категории его группы,
   в каждой группе по 20 воспитанников (вместимость групп 22-25 мест). */
;WITH C AS (
    SELECT n,
           1 + (n - 1) % 500            AS GroupId,
           1 + ((n - 1) % 500) % 6      AS Cat,
           n % 2                        AS IsFemale,
           1 + (n + n / 500) % 20       AS Si,
           1 + (n * 7 + n / 11) % 10    AS Fi,
           1 + (n + n / 7) % 10         AS Ci
    FROM dbo.Numbers
    WHERE n <= 10000
)
INSERT INTO dbo.Children (FullName, BirthDate, GroupId, EnrollmentDate, BenefitCategoryId)
SELECT CHOOSE(Si, N'Иванов', N'Петров', N'Сидоров', N'Козлов', N'Новиков', N'Морозов', N'Волков', N'Соколов', N'Лебедев', N'Ковалёв', N'Орлов', N'Зайцев', N'Павлов', N'Семёнов', N'Голубев', N'Виноградов', N'Богданов', N'Воробьёв', N'Фёдоров', N'Михайлов') + CASE WHEN IsFemale = 1 THEN N'а' ELSE N'' END + N' '
       + CASE WHEN IsFemale = 1 THEN CHOOSE(Ci, N'Анна', N'Мария', N'София', N'Алиса', N'Виктория', N'Полина', N'Дарья', N'Елена', N'Ольга', N'Екатерина') ELSE CHOOSE(Ci, N'Александр', N'Дмитрий', N'Максим', N'Иван', N'Артём', N'Михаил', N'Никита', N'Егор', N'Андрей', N'Кирилл') END + N' '
       + CASE WHEN IsFemale = 1 THEN CHOOSE(Fi, N'Александровна', N'Дмитриевна', N'Максимовна', N'Ивановна', N'Артёмовна', N'Михайловна', N'Никитична', N'Егоровна', N'Андреевна', N'Кирилловна') ELSE CHOOSE(Fi, N'Александрович', N'Дмитриевич', N'Максимович', N'Иванович', N'Артёмович', N'Михайлович', N'Никитич', N'Егорович', N'Андреевич', N'Кириллович') END,
       DATEADD(DAY, -(365 * Cat + n % 365), CAST('2025-09-01' AS DATE)),
       GroupId,
       DATEADD(DAY, 365 + n % (365 * (Cat - 1) + 1),
               DATEADD(DAY, -(365 * Cat + n % 365), CAST('2025-09-01' AS DATE))),
       CASE WHEN n % 10 < 6 THEN 1 ELSE 1 + n % 6 END
FROM C
ORDER BY n;
GO

/* 2.4. Parents - 20 000 записей (мать и отец каждого ребёнка).
   ParentId = 2*ChildId-1 - мать, ParentId = 2*ChildId - отец. */
;WITH P AS (
    SELECT n AS p,
           (n + 1) / 2          AS c,
           n % 2                AS IsMother
    FROM dbo.Numbers
    WHERE n <= 20000
)
INSERT INTO dbo.Parents (FullName, Address, Phone, Workplace)
SELECT CHOOSE(1 + (c + c / 500) % 20, N'Иванов', N'Петров', N'Сидоров', N'Козлов', N'Новиков', N'Морозов', N'Волков', N'Соколов', N'Лебедев', N'Ковалёв', N'Орлов', N'Зайцев', N'Павлов', N'Семёнов', N'Голубев', N'Виноградов', N'Богданов', N'Воробьёв', N'Фёдоров', N'Михайлов') + CASE WHEN IsMother = 1 THEN N'а' ELSE N'' END + N' '
       + CASE WHEN IsMother = 1 THEN CHOOSE(1 + (c * 3 + c / 13) % 10, N'Анна', N'Мария', N'София', N'Алиса', N'Виктория', N'Полина', N'Дарья', N'Елена', N'Ольга', N'Екатерина')
              ELSE CHOOSE(1 + (c * 7 + c / 11) % 10, N'Александр', N'Дмитрий', N'Максим', N'Иван', N'Артём', N'Михаил', N'Никита', N'Егор', N'Андрей', N'Кирилл') END + N' '
       + CASE WHEN IsMother = 1 THEN CHOOSE(1 + (c * 7 + 3 + c / 17) % 10, N'Александровна', N'Дмитриевна', N'Максимовна', N'Ивановна', N'Артёмовна', N'Михайловна', N'Никитична', N'Егоровна', N'Андреевна', N'Кирилловна')
              ELSE CHOOSE(1 + (c * 3 + c / 19) % 10, N'Александрович', N'Дмитриевич', N'Максимович', N'Иванович', N'Артёмович', N'Михайлович', N'Никитич', N'Егорович', N'Андреевич', N'Кириллович') END,
       N'г. Гомель, ул. ' + CHOOSE(1 + c % 10, N'Советская', N'Ленина', N'Мира', N'Кирова', N'Победы', N'Первомайская', N'Садовая', N'Речная', N'Школьная', N'Полесская')
           + N', д. ' + CAST(1 + c % 120 AS NVARCHAR(10))
           + N', кв. ' + CAST(1 + c % 80 AS NVARCHAR(10)),
       N'+375' + CHOOSE(1 + p % 4, N'29', N'33', N'44', N'25') + CAST(1000000 + p AS NVARCHAR(10)),
       CHOOSE(1 + p % 10, N'ОАО «Гомсельмаш»', N'Гомельская областная больница', N'ГУ «Гомельский городской исполком»', N'ОАО «Гомельдрев»', N'ИП «Прокопенко»', N'Гомельский государственный университет', N'ОАО «Белтелеком»', N'Гомельэнерго', N'ЧУП «Торговый дом»', N'Школа №12 г. Гомеля')
FROM P
ORDER BY p;
GO

/* ЭТАП 3. ТАБЛИЦЫ СТОРОНЫ «МНОГИЕ» */

/* 3.1. ChildParentLinks - 20 000 записей (два родителя на ребёнка) */
INSERT INTO dbo.ChildParentLinks (ChildId, ParentId, RelationType)
SELECT (n + 1) / 2,
       n,
       CASE WHEN n % 2 = 1 THEN N'Мать' ELSE N'Отец' END
FROM dbo.Numbers
WHERE n <= 20000
ORDER BY n;
GO

/* 3.2. Attendance - 40 000 записей (4 учебных дня для каждого воспитанника) */
INSERT INTO dbo.Attendance (ChildId, AttendanceDate, IsPresent, AbsenceReasonId)
SELECT c.ChildId,
       DATEADD(DAY, d.DayOffset, CAST('2025-09-01' AS DATE)),
       CASE WHEN (c.ChildId + d.DayOffset) % 7 = 0 THEN 0 ELSE 1 END,
       CASE WHEN (c.ChildId + d.DayOffset) % 7 = 0
            THEN 1 + (c.ChildId + d.DayOffset) % 8 ELSE NULL END
FROM dbo.Children c
CROSS JOIN (VALUES (0), (1), (2), (3)) AS d(DayOffset)
ORDER BY c.ChildId, d.DayOffset;
GO

/* 3.3. FeeCalculations - 20 000 записей (сентябрь и октябрь 2025 для каждого ребёнка).
   Оплата: ~70% - оплачено полностью, ~20% - частично, ~10% - не оплачено. */
INSERT INTO dbo.FeeCalculations (ChildId, ChargeYear, ChargeMonth, AttendedDays, PaidAmount, PaymentDate)
SELECT c.ChildId,
       2025,
       m.ChargeMonth,
       x.AttendedDays,
       CASE WHEN (c.ChildId + m.ChargeMonth) % 10 < 7 THEN t.Total
            WHEN (c.ChildId + m.ChargeMonth) % 10 < 9 THEN CAST(t.Total / 2 AS DECIMAL(18,2))
            ELSE CAST(0 AS DECIMAL(18,2)) END,
       CASE WHEN (c.ChildId + m.ChargeMonth) % 10 < 9
            THEN DATEFROMPARTS(2025, m.ChargeMonth, 5 + c.ChildId % 20) ELSE NULL END
FROM dbo.Children c
JOIN dbo.Groups            g  ON g.GroupId            = c.GroupId
JOIN dbo.AgeCategories     ac ON ac.AgeCategoryId     = g.AgeCategoryId
JOIN dbo.BenefitCategories bc ON bc.BenefitCategoryId = c.BenefitCategoryId
CROSS JOIN (VALUES (9), (10)) AS m(ChargeMonth)
CROSS APPLY (SELECT 14 + (c.ChildId + m.ChargeMonth) % 8 AS AttendedDays) x
CROSS APPLY (SELECT CAST(x.AttendedDays * ac.DailyMealCost * (1 - bc.DiscountPercent / 100.0)
                         AS DECIMAL(18,2)) AS Total) t
ORDER BY c.ChildId, m.ChargeMonth;
GO

/* 3.4. DailyMenus - меню на 5 дней для 6 возрастных категорий (завтрак, обед, полдник) */
INSERT INTO dbo.DailyMenus (MenuDate, AgeCategoryId, MealTypeId)
SELECT DATEADD(DAY, d.DayOffset, CAST('2025-09-01' AS DATE)), a.AgeCategoryId, m.MealTypeId
FROM (VALUES (0), (1), (2), (3), (4)) AS d(DayOffset)
CROSS JOIN dbo.AgeCategories a
CROSS JOIN (VALUES (1), (3), (4)) AS m(MealTypeId)
ORDER BY d.DayOffset, a.AgeCategoryId, m.MealTypeId;
GO

/* 3.5. MenuDishLinks - по 3 блюда на каждый приём пищи
   (блюда 1-12 - завтрак, 13-30 - обед, 31-40 - полдник) */
INSERT INTO dbo.MenuDishLinks (DailyMenuId, DishId)
SELECT dm.DailyMenuId,
       CASE dm.MealTypeId WHEN 1 THEN 1 WHEN 3 THEN 13 ELSE 31 END
       + (CAST(dm.DailyMenuId AS INT) * 3 + k.K)
         % CASE dm.MealTypeId WHEN 1 THEN 12 WHEN 3 THEN 18 ELSE 10 END
FROM dbo.DailyMenus dm
CROSS JOIN (VALUES (0), (1), (2)) AS k(K)
ORDER BY dm.DailyMenuId, k.K;
GO

/* Удаляем вспомогательную таблицу */
DROP TABLE dbo.Numbers;
GO

/* ПРОВЕРКА ОБЪЁМОВ */
SELECT 'AgeCategories'     AS TableName, COUNT(*) AS RowCnt FROM dbo.AgeCategories
UNION ALL SELECT 'BenefitCategories', COUNT(*) FROM dbo.BenefitCategories
UNION ALL SELECT 'AbsenceReasons',    COUNT(*) FROM dbo.AbsenceReasons
UNION ALL SELECT 'MealTypes',         COUNT(*) FROM dbo.MealTypes
UNION ALL SELECT 'Dishes',            COUNT(*) FROM dbo.Dishes
UNION ALL SELECT 'Groups',            COUNT(*) FROM dbo.Groups
UNION ALL SELECT 'Educators',         COUNT(*) FROM dbo.Educators
UNION ALL SELECT 'Parents',           COUNT(*) FROM dbo.Parents
UNION ALL SELECT 'Children',          COUNT(*) FROM dbo.Children
UNION ALL SELECT 'ChildParentLinks',  COUNT(*) FROM dbo.ChildParentLinks
UNION ALL SELECT 'Attendance',        COUNT(*) FROM dbo.Attendance
UNION ALL SELECT 'FeeCalculations',   COUNT(*) FROM dbo.FeeCalculations
UNION ALL SELECT 'DailyMenus',        COUNT(*) FROM dbo.DailyMenus
UNION ALL SELECT 'MenuDishLinks',     COUNT(*) FROM dbo.MenuDishLinks
ORDER BY TableName;
GO
PRINT N'Тестовые данные успешно загружены.';
GO
