using CafeEase.Model;
using System.Collections.Generic;

namespace CafeEase.Services.Database
{
    public class Category
    {
        public int Id { get; set; }
        public string? Name { get; set; }
        public virtual ICollection<Product> Products { get; set; } = new List<Product>();
    }
}
