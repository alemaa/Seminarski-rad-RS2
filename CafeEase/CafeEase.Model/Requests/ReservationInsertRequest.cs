using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel;

namespace CafeEase.Model.Requests
{
    public class ReservationInsertRequest
    {
        public int TableId { get; set; }
        public DateTime ReservationDateTime { get; set; }

        [DefaultValue(2)]
        [Range(1, int.MaxValue, ErrorMessage = "Number of guests must be at least 1.")]
        public int NumberOfGuests { get; set; } = 2;
        public string? Status { get; set; }

        [DefaultValue(120)]
        [Range(15, 480, ErrorMessage = "Duration must be between 15 and 480 minutes.")]
        public int DurationMinutes { get; set; } = 120;
    }
}
