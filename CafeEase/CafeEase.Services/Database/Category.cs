using CafeEase.Model;
using System.Collections.Generic;

namespace CafeEase.Services.Database
{
    public class Category
    {
        public int Id { get; set; }
        public string Name { get; set; } = null!;
        public virtual ICollection<Product> Products { get; set; } = new List<Product>();
        public ICollection<PromotionCategory> PromotionCategories { get; set; } = new List<PromotionCategory>();
    }
}
