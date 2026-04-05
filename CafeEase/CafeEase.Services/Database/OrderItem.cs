namespace CafeEase.Services.Database
{
    public class OrderItem
    {
        public int Id { get; set; }

        public int OrderId { get; set; }
        public virtual Order Order { get; set; } = null!;

        public int ProductId { get; set; }
        public virtual Product Product { get; set; } = null!; 

        public int Quantity { get; set; }
        public decimal Price { get; set; }
        public string? Size { get; set; } 
        public string? MilkType { get; set; }  
        public int? SugarLevel { get; set; }   
        public string? Note { get; set; }      
    }
}
