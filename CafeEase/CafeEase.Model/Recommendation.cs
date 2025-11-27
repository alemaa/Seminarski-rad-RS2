using System;
using System.Collections.Generic;
using System.Text;

namespace CafeEase.Model
{
    public class Recommendation
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public User? User { get; set; }
        public int ProductId { get; set; }
        public Product? Product { get; set; }
        public double Score { get; set; }
    }
}
