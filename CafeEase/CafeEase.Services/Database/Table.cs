using System.Collections.Generic;

namespace CafeEase.Services.Database
{
    public class Table
    {
        public int Id { get; set; }

        public int Number { get; set; }
        public int Capacity { get; set; }
        public bool IsOccupied { get; set; }

        public virtual ICollection<Order> Orders { get; set; } = new List<Order>();
    }
}
