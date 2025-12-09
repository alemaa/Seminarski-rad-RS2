using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Model.Requests
{
    public class LoyaltyPointsInsertRequest
    {
        public int UserId { get; set; }
        public int Points { get; set; }
    }

}
