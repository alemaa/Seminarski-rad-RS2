using CafeEase.Model;
using System.Collections.Generic;

namespace CafeEase.Services.Database
{
    public class User
    {
        public int Id { get; set; }
        public string FirstName { get; set; } = null!;
        public string LastName { get; set; } = null!;
        public string Username { get; set; } = null!;
        public string Email { get; set; } = null!;
        public string PasswordHash { get; set; } = null!;
        public string PasswordSalt { get; set; } = null!;
        public int RoleId { get; set; }
        public virtual Role Role { get; set; } = null!;
        public virtual ICollection<Order> Orders { get; set; } = new List<Order>();
        public virtual LoyaltyPoints? LoyaltyPoints { get; set; }
        public int CityId { get; set; }
        public virtual City City { get; set; } = null!;
    }
}
