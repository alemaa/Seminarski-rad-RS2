using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Model.Requests
{
    public class PromotionInsertRequest
    {
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public double DiscountPercent { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public List<int> CategoryIds { get; set; }
        public string? TargetSegment { get; set; }
    }
}
