using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Services.Database
{
    public class Notification
    {
        public int Id { get; set; }

        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        public int? OrderId { get; set; }

        public string Title { get; set; } = null!;
        public string Body { get; set; } = null!;

        public bool IsRead { get; set; } = false;
        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
