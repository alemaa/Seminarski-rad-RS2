using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Model.Requests
{
    public class OrderInsertRequest
    {
        public int UserId { get; set; }
        public int TableId { get; set; }
        public int CityId { get; set; }
        public List<OrderItemInsertRequest>? Items { get; set; }
    }
}
