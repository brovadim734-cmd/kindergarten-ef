using System;
using System.Collections.Generic;

namespace KindergartenEf.Models;

public partial class DailyMenu
{
    public long DailyMenuId { get; set; }

    public DateOnly MenuDate { get; set; }

    public int AgeCategoryId { get; set; }

    public int MealTypeId { get; set; }

    public virtual AgeCategory AgeCategory { get; set; } = null!;

    public virtual MealType MealType { get; set; } = null!;

    public virtual ICollection<Dish> Dishes { get; set; } = new List<Dish>();
}
