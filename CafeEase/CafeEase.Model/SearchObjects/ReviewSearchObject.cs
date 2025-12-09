using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Model.SearchObjects
{
    public class ReviewSearchObject : BaseSearchObject
    {
        public int? ProductId { get; set; }
        public int? UserId { get; set; }
    }
}
