using System;
using System.Collections.Generic;

namespace KindergartenEf.Models;

public partial class ChildParentLink
{
    public int ChildId { get; set; }

    public int ParentId { get; set; }

    public string RelationType { get; set; } = null!;

    public virtual Child Child { get; set; } = null!;

    public virtual Parent Parent { get; set; } = null!;
}
