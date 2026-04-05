using System;
using System.Collections.Generic;
using System.Text;

namespace CafeEase.Model
{
    public class OrderItem
    {
        public int Id { get; set; }
        public int OrderId { get; set; }
        public int ProductId { get; set; }
        public string ProductName { get; set; }
        public int Quantity { get; set; }
        public decimal Price { get; set; }
        public string? Size { get; set; }
        public string? MilkType { get; set; }
        public int? SugarLevel { get; set; }
        public string? Note { get; set; }
    }
}
