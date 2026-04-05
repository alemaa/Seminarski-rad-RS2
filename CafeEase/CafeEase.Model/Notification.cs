using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Model
{
    public class Notification
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int? OrderId { get; set; }

        public string? Title { get; set; }
        public string? Body { get; set; }

        public bool IsRead { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
