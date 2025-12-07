using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Model.Requests
{
    public class OrderUpdateRequest
    {
        public string? Status { get; set; }
        public int? Quantity {  get; set; } 
        public int? TableId { get; set; }
    }
}
