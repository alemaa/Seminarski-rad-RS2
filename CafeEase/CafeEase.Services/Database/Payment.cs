using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Services.Database
{
    public class Payment
    {
        public int Id { get; set; }
        public string Method { get; set; }
        public string Status { get; set; }
        public int OrderId { get; set; }
        public virtual Order Order { get; set; }
    }
}
