using System;
using System.Collections.Generic;

namespace KindergartenEf.Models;

public partial class FeeCalculation
{
    public long FeeCalculationId { get; set; }

    public int ChildId { get; set; }

    public int ChargeYear { get; set; }

    public int ChargeMonth { get; set; }

    public int AttendedDays { get; set; }

    public decimal PaidAmount { get; set; }

    public DateOnly? PaymentDate { get; set; }

    public virtual Child Child { get; set; } = null!;
}
