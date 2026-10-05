using System;
using System.Collections.Generic;

namespace KindergartenEf.Models;

public partial class Group
{
    public int GroupId { get; set; }

    public string Name { get; set; } = null!;

    public int AgeCategoryId { get; set; }

    public int Capacity { get; set; }

    public virtual AgeCategory AgeCategory { get; set; } = null!;

    public virtual ICollection<Child> Children { get; set; } = new List<Child>();

    public virtual ICollection<Educator> Educators { get; set; } = new List<Educator>();
}
