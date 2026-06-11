using System.Collections.Generic;

namespace CafeEase.Model.Responses;

public class ReportDataResponse
{
    public List<Order> Orders { get; set; } = [];
    public List<Inventory> Inventory { get; set; } = [];
    public List<OrderItem> PaidOrderItems { get; set; } = [];
}
