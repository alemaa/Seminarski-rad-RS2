using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Model.Requests
{
    public class TableInsertRequest
    {
        [DefaultValue(1)]
        [Range(1, int.MaxValue, ErrorMessage = "Table number must be at least 1.")]
        public int Number { get; set; } = 1;

        [DefaultValue(2)]
        [Range(1, int.MaxValue, ErrorMessage = "Capacity must be at least 1.")]
        public int Capacity { get; set; } = 2;

        [DefaultValue(false)]
        public bool IsOccupied { get; set; } = false;
    }
}
