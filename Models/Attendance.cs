using System;
using System.Collections.Generic;

namespace KindergartenEf.Models;

public partial class Attendance
{
    public long AttendanceId { get; set; }

    public int ChildId { get; set; }

    public DateOnly AttendanceDate { get; set; }

    public bool IsPresent { get; set; }

    public int? AbsenceReasonId { get; set; }

    public virtual AbsenceReason? AbsenceReason { get; set; }

    public virtual Child Child { get; set; } = null!;
}
