using CafeEase.Model;
using System.Collections.Generic;
using System;

namespace CafeEase.Services.Database
{
    public class Order
    {
        public int Id { get; set; }

        public DateTime OrderDate { get; set; }
        public decimal TotalAmount { get; set; }
        public string Status { get; set; } = null!;
        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        public int TableId { get; set; }
        public virtual Table Table { get; set; } = null!;

        public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
    }
}
