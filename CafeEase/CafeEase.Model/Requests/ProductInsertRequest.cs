using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;

namespace CafeEase.Model.Requests
{
    public class ProductInsertRequest
    {
        [Required(AllowEmptyStrings = false)]
        public string Name { get; set; } = null!;

        [Required]
        [Range(0.1, 10000)]
        public decimal Price { get; set; }
        public string? Description { get; set; }
        public byte[]? Image { get; set; }

        [Required]
        public int CategoryId { get; set; }
    }
}
