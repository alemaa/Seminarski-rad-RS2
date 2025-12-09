using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Model.Requests
{
    public class PaymentInsertRequest
    {
        public int OrderId { get; set; }
        public string Method { get; set; } = null!;
    }

}
