using System;
using System.Collections.Generic;

namespace KindergartenEf.Models;

public partial class Educator
{
    public int EducatorId { get; set; }

    public string FullName { get; set; } = null!;

    public string Education { get; set; } = null!;

    public string WorkSchedule { get; set; } = null!;

    public int GroupId { get; set; }

    public virtual Group Group { get; set; } = null!;
}
