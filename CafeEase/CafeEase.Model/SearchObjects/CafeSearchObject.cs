using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Model.SearchObjects
{
    public class CafeSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public int? CityId { get; set; }
        public bool? IsActive { get; set; }
        public double? Latitude { get; set; }
        public double? Longitude { get; set; }
    }
}