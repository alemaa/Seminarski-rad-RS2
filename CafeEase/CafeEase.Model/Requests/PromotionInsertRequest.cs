using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel;

namespace CafeEase.Model.Requests
{
    public class PromotionInsertRequest
    {
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }

        [DefaultValue(10)]
        [Range(0, 100, ErrorMessage = "Discount percent must be between 0 and 100.")]
        public double DiscountPercent { get; set; } = 10;
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public List<int> CategoryIds { get; set; } = new() { 1 };

        [DefaultValue("ALL")]
        public string? TargetSegment { get; set; }
    }
}
