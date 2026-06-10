using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel;

namespace CafeEase.Model.Requests
{
    public class ProductInsertRequest
    {
        [Required(AllowEmptyStrings = false)]
        public string Name { get; set; } = null!;

        [DefaultValue(1)]
        [Range(0.01, double.MaxValue, ErrorMessage = "Price must be greater than 0.")]
        public decimal Price { get; set; } = 1;
        public string? Description { get; set; }
        public string? ImagePath { get; set; }

        [Required]
        public int CategoryId { get; set; }
    }
}
