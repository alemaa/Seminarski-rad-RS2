using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Model.Requests
{
    public class ReservationUpdateRequest
    {
        public DateTime? ReservationDateTime { get; set; }
        public int? NumberOfGuests { get; set; }
        public string? Status { get; set; }

        public int? TableId { get; set; }
    }
}
