using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Model.Requests
{
    public class ReservationUpdateRequest
    {
        public DateTime? ReservationDateTime { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Number of guests must be at least 1.")]
        public int? NumberOfGuests { get; set; }
        public string? Status { get; set; }

        public int? TableId { get; set; }
    }
}
