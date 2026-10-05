using System;
using System.Collections.Generic;

namespace KindergartenEf.Models;

public partial class Parent
{
    public int ParentId { get; set; }

    public string FullName { get; set; } = null!;

    public string? Address { get; set; }

    public string? Phone { get; set; }

    public string? Workplace { get; set; }

    public virtual ICollection<ChildParentLink> ChildParentLinks { get; set; } = new List<ChildParentLink>();
}
