using System;
using System.Collections.Generic;

namespace KindergartenEf.Models;

public partial class Dish
{
    public int DishId { get; set; }

    public string Name { get; set; } = null!;

    public virtual ICollection<DailyMenu> DailyMenus { get; set; } = new List<DailyMenu>();
}
