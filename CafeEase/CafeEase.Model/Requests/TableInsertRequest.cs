using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Model.Requests
{
    public class TableInsertRequest
    {
        public int Number { get; set; }
        public int Capacity { get; set; }
        public bool IsOccupied { get; set; }
    }
}
