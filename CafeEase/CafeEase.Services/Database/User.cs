using CafeEase.Model;
using System.Collections.Generic;

namespace CafeEase.Services.Database
{
    public class User
    {
        public int Id { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? Username { get; set; }
        public string? Email { get; set; }
        public string? PasswordHash { get; set; }
        public string? PasswordSalt { get; set; }
        public int RoleId { get; set; }
        public virtual Role Role { get; set; }
        public virtual ICollection<Order> Orders { get; set; } = new List<Order>();
        public virtual LoyaltyPoints LoyaltyPoints { get; set; }
    }
}
