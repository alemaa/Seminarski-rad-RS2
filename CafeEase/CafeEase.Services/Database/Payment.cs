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
        public string Method { get; set; } = null!;
        public string Status { get; set; } = null!;
        public int OrderId { get; set; }
        public virtual Order Order { get; set; } = null!;
    }
}
