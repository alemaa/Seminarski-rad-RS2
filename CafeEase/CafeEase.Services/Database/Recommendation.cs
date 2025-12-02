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
        public int UserId { get; set; }
        public virtual User User { get; set; }
        public int ProductId { get; set; }
        public virtual Product Product { get; set; }
        public double Score { get; set; }
    }
}
