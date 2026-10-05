using System;
using System.Collections.Generic;

namespace KindergartenEf.Models;

public partial class Child
{
    public int ChildId { get; set; }

    public string FullName { get; set; } = null!;

    public DateOnly BirthDate { get; set; }

    public int? GroupId { get; set; }

    public DateOnly EnrollmentDate { get; set; }

    public int BenefitCategoryId { get; set; }

    public virtual ICollection<Attendance> Attendances { get; set; } = new List<Attendance>();

    public virtual BenefitCategory BenefitCategory { get; set; } = null!;

    public virtual ICollection<ChildParentLink> ChildParentLinks { get; set; } = new List<ChildParentLink>();

    public virtual ICollection<FeeCalculation> FeeCalculations { get; set; } = new List<FeeCalculation>();

    public virtual Group? Group { get; set; }
}
