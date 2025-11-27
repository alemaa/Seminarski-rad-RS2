using System;
using System.Collections.Generic;
using System.Text;

namespace CafeEase.Model
{
    public class LoyaltyPoints
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public User? User { get; set; }
        public int Points { get; set; }
        public DateTime LastUpdated { get; set; }
    }
}
