using System;
using System.Collections.Generic;

namespace KindergartenEf.Models;

public partial class AbsenceReason
{
    public int AbsenceReasonId { get; set; }

    public string Name { get; set; } = null!;

    public virtual ICollection<Attendance> Attendances { get; set; } = new List<Attendance>();
}
