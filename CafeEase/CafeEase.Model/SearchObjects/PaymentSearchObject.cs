using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Model.SearchObjects
{
    public class PaymentSearchObject : BaseSearchObject
    {
        public int? OrderId { get; set; }
        public string? Status { get; set; }
    }
}
