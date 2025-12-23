using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Services.Database
{
    public class PromotionCategory
    {
        public int PromotionId { get; set; }
        public Promotion Promotion { get; set; } = null!;   
        public int CategoryId { get; set; }
        public Category Category { get; set; } = null!;
    }
}
