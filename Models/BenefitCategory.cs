using System;
using System.Collections.Generic;

namespace KindergartenEf.Models;

public partial class BenefitCategory
{
    public int BenefitCategoryId { get; set; }

    public string Name { get; set; } = null!;

    public decimal DiscountPercent { get; set; }

    public virtual ICollection<Child> Children { get; set; } = new List<Child>();
}
