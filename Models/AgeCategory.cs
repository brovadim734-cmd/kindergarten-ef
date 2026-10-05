using System;
using System.Collections.Generic;

namespace KindergartenEf.Models;

public partial class AgeCategory
{
    public int AgeCategoryId { get; set; }

    public string Name { get; set; } = null!;

    public decimal DailyMealCost { get; set; }

    public virtual ICollection<DailyMenu> DailyMenus { get; set; } = new List<DailyMenu>();

    public virtual ICollection<Group> Groups { get; set; } = new List<Group>();
}
