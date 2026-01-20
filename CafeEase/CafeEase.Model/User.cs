using System.Collections.Generic;

namespace CafeEase.Model
{
    public class User
    {
        public int Id { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? Username { get; set; }
        public string? Email { get; set; }
        public int RoleId { get; set; }
        public int? CityId { get; set; }
    }
}
