using System;
using System.Collections.Generic;
using System.Text;

namespace CafeEase.Model
{
    public class Table
    {
        public int Id { get; set; }
        public int Number { get; set; }
        public int Capacity { get; set; }
        public bool IsOccupied { get; set; }
    }
}
