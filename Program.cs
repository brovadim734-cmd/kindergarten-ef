using KindergartenEf.Models;
using Microsoft.EntityFrameworkCore;

using var db = new KindergartenContext();

void Title(string s) => Console.WriteLine($"\n===== {s} =====");

// 2.1 Выборка всех данных из таблицы на стороне «один» (AgeCategories)
Title("2.1 Все возрастные категории");
foreach (var a in db.AgeCategories.ToList())
    Console.WriteLine($"{a.AgeCategoryId}. {a.Name} — {a.DailyMealCost} руб./день");

// 2.2 Выборка из таблицы на стороне «один» с условием по нескольким полям (Groups)
Title("2.2 Группы с вместимостью >= 24 и названием «Ромашка» (первые 10)");
var filteredGroups = db.Groups
    .Where(g => g.Capacity >= 24 && g.Name.Contains("Ромашка"))
    .OrderBy(g => g.GroupId)
    .Take(10)
    .ToList();
foreach (var g in filteredGroups)
    Console.WriteLine($"{g.GroupId}. {g.Name} (мест: {g.Capacity})");

// 2.3 Группировка по полю в таблице на стороне «многие» (Children) с итогами
Title("2.3 Дети по категориям льгот: количество и самая ранняя дата рождения");
var byBenefit = db.Children
    .GroupBy(c => c.BenefitCategoryId)
    .Select(x => new
    {
        BenefitCategoryId = x.Key,
        Count = x.Count(),
        MinBirth = x.Min(c => c.BirthDate)
    })
    .OrderBy(x => x.BenefitCategoryId)
    .ToList();
foreach (var x in byBenefit)
    Console.WriteLine($"Категория льгот {x.BenefitCategoryId}: детей {x.Count}, самый старший родился {x.MinBirth:dd.MM.yyyy}");

// 2.4 Два поля из двух связанных таблиц (Children — Groups)
Title("2.4 Ребёнок — группа (первые 10)");
var pairs = db.Children
    .OrderBy(c => c.ChildId)
    .Select(c => new { c.FullName, GroupName = c.Group != null ? c.Group.Name : "(без группы)" })
    .Take(10)
    .ToList();
foreach (var p in pairs)
    Console.WriteLine($"{p.FullName} — {p.GroupName}");

// 2.5 Две связанные таблицы с условием
Title("2.5 Дети, зачисленные с 01.01.2025, с группой и возрастной категорией (первые 10)");
var filtered = db.Children
    .Where(c => c.EnrollmentDate >= new DateOnly(2025, 1, 1) && c.Group != null)
    .OrderBy(c => c.EnrollmentDate)
    .Select(c => new
    {
        c.FullName,
        c.EnrollmentDate,
        GroupName = c.Group!.Name,
        Category = c.Group.AgeCategory.Name
    })
    .Take(10)
    .ToList();
foreach (var f in filtered)
    Console.WriteLine($"{f.FullName} | {f.EnrollmentDate:dd.MM.yyyy} | {f.GroupName} | {f.Category}");

// 2.6 Вставка на стороне «один» (Groups)
Title("2.6 Вставка группы");
var ageCat = db.AgeCategories.First();
var newGroup = new Group
{
    Name = "Тестовая группа " + DateTime.Now.ToString("HHmmss"),   // Name уникально
    AgeCategoryId = ageCat.AgeCategoryId,
    Capacity = 10
};
db.Groups.Add(newGroup);
db.SaveChanges();
Console.WriteLine($"Добавлена группа Id = {newGroup.GroupId}, «{newGroup.Name}»");

// 2.7 Вставка на стороне «многие» (Children)
Title("2.7 Вставка ребёнка");
var benefit = db.BenefitCategories.First();
var newChild = new Child
{
    FullName = "Тестов Тест Тестович",
    BirthDate = new DateOnly(2021, 5, 10),
    EnrollmentDate = new DateOnly(2024, 9, 1),
    GroupId = newGroup.GroupId,
    BenefitCategoryId = benefit.BenefitCategoryId
};
db.Children.Add(newChild);
db.SaveChanges();
Console.WriteLine($"Добавлен ребёнок Id = {newChild.ChildId}");

// 2.8 Удаление на стороне «один» (Groups)
Title("2.8 Удаление группы");
// у ребёнка из этой группы GroupId станет NULL (ON DELETE SET NULL)
db.Groups.Remove(newGroup);
db.SaveChanges();
Console.WriteLine("Группа удалена, у тестового ребёнка GroupId = NULL");

// 2.9 Удаление на стороне «многие» (Children)
Title("2.9 Удаление ребёнка");
db.Children.Remove(newChild);
db.SaveChanges();
Console.WriteLine("Тестовый ребёнок удалён");

// 2.10 Обновление записей по условию
Title("2.10 Обновление: у групп «Солнышко» вместимостью 23 увеличить вместимость до 25");
var toUpdate = db.Groups
    .Where(g => g.Capacity == 23 && g.Name.Contains("Солнышко"))
    .ToList();
foreach (var g in toUpdate)
    g.Capacity = 25;
int changed = db.SaveChanges();
Console.WriteLine($"Обновлено записей: {changed}");
Console.ReadKey();