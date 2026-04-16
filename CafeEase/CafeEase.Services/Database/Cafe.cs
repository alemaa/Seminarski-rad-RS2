using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Services.Database
{
    public class Cafe
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;

        public int CityId { get; set; }
        public City City { get; set; } = null!;

        public double Latitude { get; set; }
        public double Longitude { get; set; }

        public string? PhoneNumber { get; set; }
        public string? WorkingHours { get; set; }

        public bool IsActive { get; set; } = true;
    }
}
