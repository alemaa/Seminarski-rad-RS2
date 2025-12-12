using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Services.Database
{
    public class Recommendation
    {
        public int Id { get; set; }
        public int ProductId { get; set; }
        public int RecommendedProductId { get; set; }
        public double Score { get; set; }
    }
}
