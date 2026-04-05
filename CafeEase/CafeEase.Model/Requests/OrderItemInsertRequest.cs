using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Model.Requests
{
    public class OrderItemInsertRequest
    {
        public int ProductId { get; set; }
        public int Quantity { get; set; }
        public string? Size { get; set; }
        public string? MilkType { get; set; }
        public int? SugarLevel { get; set; }
        public string? Note { get; set; }
    }
}
