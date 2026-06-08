using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Model.Requests
{
    public class TableInsertRequest
    {
        public int Number { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Capacity must be at least 1.")]
        public int Capacity { get; set; }
        public bool IsOccupied { get; set; }
    }
}
