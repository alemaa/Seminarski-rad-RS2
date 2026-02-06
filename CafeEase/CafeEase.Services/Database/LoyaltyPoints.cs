using System;

namespace CafeEase.Services.Database
{
    public class LoyaltyPoints
    {
        public int Id { get; set; }

        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;
        public DateTime LastUpdated { get; set; }
        public int Points { get; set; }
    }
}
