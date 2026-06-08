using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Model.Requests
{
    public class PromotionUpdateRequest
    {
        public string? Name { get; set; }
        public string? Description { get; set; }

        [Range(0, 100, ErrorMessage = "Discount percent must be between 0 and 100.")]
        public double? DiscountPercent { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public List<int>? CategoryIds { get; set; }
        public string? TargetSegment { get; set; }
    }
}
