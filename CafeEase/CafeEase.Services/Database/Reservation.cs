using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Services.Database
{
    public class Reservation
    {
        public int Id { get; set; }

        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        public int TableId { get; set; }
        public virtual Table Table { get; set; } = null!;

        public DateTime ReservationDateTime { get; set; }
        public int NumberOfGuests { get; set; }

        public string Status { get; set; } = "Pending";
    }
}
