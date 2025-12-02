using CafeEase.Model;
using System.Collections.Generic;

namespace CafeEase.Services.Database
{
    public class City
    {
        public int Id { get; set; }
        public string? Name { get; set; }
        public virtual ICollection<Order> Orders { get; set; } = new List<Order>();
    }
}