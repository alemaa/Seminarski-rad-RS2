using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;

namespace CafeEase.Model.Requests
{
    public class ReviewInsertRequest
    {
        public int ProductId { get; set; }

        [Range(1, 5, ErrorMessage = "Rating must be between 1 and 5.")]
        public int Rating { get; set; }
        public string? Comment { get; set; }
    }
}
