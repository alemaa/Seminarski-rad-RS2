using System;
using System.Collections.Generic;
using System.Text;

namespace CafeEase.Model
{
    public class Recommendation
    {
        public int Id { get; set; }
        public int ProductId { get; set; }
        public int RecommendedProductId { get; set; }
        public double Score { get; set; }
    }
}
