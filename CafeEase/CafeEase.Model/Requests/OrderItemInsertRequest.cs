using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel;

namespace CafeEase.Model.Requests
{
    public class OrderItemInsertRequest
    {
        public int ProductId { get; set; }

        [DefaultValue(1)]
        [Range(1, int.MaxValue, ErrorMessage = "Quantity must be at least 1.")] 
        public int Quantity { get; set; } = 1;
        public string? Size { get; set; }
        public string? MilkType { get; set; }
        public int? SugarLevel { get; set; }
        public string? Note { get; set; }
    }
}
