using CafeEase.Model;
using System.Collections.Generic;

namespace CafeEase.Services.Database
{
    public class Product
    {
        public int Id { get; set; }

        public string Name { get; set; } = null!;
        public decimal Price { get; set; }
        public string? Description { get; set; } 
        public byte[]? Image { get; set; }
        public int CategoryId { get; set; }
        public virtual Category Category { get; set; } = null!;

        public virtual Inventory Inventory { get; set; } = null!;

        public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
    }
}
