using System;
using System.Collections.Generic;
using System.Text;

namespace CafeEase.Model
{
    public class Promotion
    {
        public int Id { get; set; }
        public string? Name { get; set; }
        public string? Description { get; set; }
        public double DiscountPercent { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public string? Role { get; set; }   
        public string? TargetSegment { get; set; }
        public List<Category> Categories { get; set; } = new();  
    }
}
