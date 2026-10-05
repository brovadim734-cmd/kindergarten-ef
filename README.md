# Kindergarten EF Core

[![Build](https://github.com/brovadim734-cmd/kindergarten-ef/actions/workflows/build.yml/badge.svg)](https://github.com/brovadim734-cmd/kindergarten-ef/actions/workflows/build.yml)

Консольное .NET‑приложение, демонстрирующее работу с базой данных
`Kindergarten` (MS SQL Server) через **Entity Framework Core** (подход
Database First) и **LINQ**.

## Возможности

- Выборка, фильтрация, группировка и соединение данных через LINQ
- Вставка, обновление и удаление записей через `DbContext`
- Модели сущностей сгенерированы из существующей БД (Database First, scaffolding)

## Стек

- .NET 10
- Entity Framework Core 10 (`Microsoft.EntityFrameworkCore.SqlServer`)
- MS SQL Server

## Структура проекта

```
KindergartenEf/
├── .github/workflows/build.yml   # CI: сборка под Ubuntu и Windows
├── Models/                        # сущности + KindergartenContext
├── appsettings.json               # строка подключения
├── Program.cs                     # LINQ-запросы и CRUD-операции
└── KindergartenEf.csproj
```

## Строка подключения

Хранится в `appsettings.json`:

```json
{
  "ConnectionStrings": {
    "Kindergarten": "Server=localhost;Database=Kindergarten;Trusted_Connection=True;TrustServerCertificate=True"
  }
}
```

Читается в `KindergartenContext.OnConfiguring` через `ConfigurationBuilder`:

```csharp
var config = new ConfigurationBuilder()
    .SetBasePath(AppContext.BaseDirectory)
    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
    .Build();

var cs = config.GetConnectionString("Kindergarten");
optionsBuilder.UseSqlServer(cs);
```

## Запуск

1. Создать БД и заполнить тестовыми данными скриптами `01_create_tables.sql`
   и `02_seed_data.sql`.
2. Проверить строку подключения в `appsettings.json`.
3. Выполнить:

   ```bash
   dotnet run --project KindergartenEf.csproj
   ```

## Сборка

```bash
dotnet restore KindergartenEf.csproj
dotnet build KindergartenEf.csproj -c Release
dotnet publish KindergartenEf.csproj -c Release -o ./publish
```

## CI

GitHub Actions workflow [`build.yml`](.github/workflows/build.yml) собирает
и публикует проект под **Ubuntu** и **Windows** при каждом пуше и pull request
в `main`.