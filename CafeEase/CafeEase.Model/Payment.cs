using System;
using System.Collections.Generic;
using System.Text;

namespace CafeEase.Model
{
    public class Payment
    {
        public int Id { get; set; }
        public string? Method { get; set; }
        public string? Status { get; set; }
        public int OrderId { get; set; }
    }
}
