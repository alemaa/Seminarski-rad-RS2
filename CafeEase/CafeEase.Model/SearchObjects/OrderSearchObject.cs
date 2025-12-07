using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Model.SearchObjects
{
    public class OrderSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? TableId { get; set; }
        public string? Status { get; set; }
    }
}
