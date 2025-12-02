using System.Collections.Generic;

namespace CafeEase.Services.Database
{
    public class Role
    {
        public int Id { get; set; }
        public string? Name { get; set; }
        public virtual ICollection<User> Users { get; set; } = new List<User>();
    }
}