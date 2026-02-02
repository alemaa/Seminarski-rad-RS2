using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Model.SearchObjects
{
    public class PromotionSearchObject : BaseSearchObject
    {
        public bool? ActiveOnly { get; set; }
        public string? Role { get; set; }
        public string? Segment { get; set; }
    }
}
