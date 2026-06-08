using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;

namespace CafeEase.Model.Requests
{
    public class ReservationInsertRequest
    {
        public int TableId { get; set; }
        public DateTime ReservationDateTime { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Number of guests must be at least 1.")]
        public int NumberOfGuests { get; set; }
        public string? Status { get; set; }

        [Range(15, 480, ErrorMessage = "Duration must be between 15 and 480 minutes.")]
        public int DurationMinutes { get; set; } = 120;
    }
}
