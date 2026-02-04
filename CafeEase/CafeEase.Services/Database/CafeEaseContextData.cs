using CafeEase.Model;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Services.Database
{
    public partial class CafeEaseDbContext
    {
        partial void OnModelCreatingPartial(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Role>().HasData(
            new Role { Id = 1, Name = "Admin" },
            new Role { Id = 2, Name = "Mobile" }
            );

            modelBuilder.Entity<City>().HasData(
            new City { Id = 1, Name = "Sarajevo" },
            new City { Id = 2, Name = "Mostar" },
            new City { Id = 3, Name = "Tuzla" }
            );

            modelBuilder.Entity<User>().HasData(
             new User
             {
                 Id = 1,
                 FirstName = "Admin",
                 LastName = "Admin",
                 Username = "desktop",
                 Email = "admin@cafeease.com",
                 PasswordHash = "L0uD9aDjQiZ6US9mT63C+tMvcSk=",
                 PasswordSalt = "js30TX4cHnStZnZM8pWbcg==",
                 RoleId = 1,
                 CityId = 1,
             },
             new User
             {
                 Id = 2,
                 FirstName = "Mobile",
                 LastName = "User",
                 Username = "mobile",
                 Email = "mobileuser@cafeease.com",
                 PasswordHash = "w6NEGcaz3XwZej0uJcY1mJIWrAI=",
                 PasswordSalt = "tNcmHa/vi33ilAmQImsPhg==",
                 RoleId = 2,
                 CityId = 2,
             },
             new User
             {
                 Id = 3,
                 FirstName = "Test",
                 LastName = "User",
                 Username = "test",
                 Email = "test@cafeease.com",
                 PasswordHash = "dlKlLumk23Dx2D3OgAiBbZsFmfo=",
                 PasswordSalt = "ym5obohaOyqCOlyuhaGxGQ==",
                 RoleId = 2,
                 CityId = 3,
             }
            );

            modelBuilder.Entity<Category>().HasData(
                new Category { Id = 1, Name = "Coffee" },
                new Category { Id = 2, Name = "Cold Drinks" },
                new Category { Id = 3, Name = "Desserts" },
                new Category { Id = 4, Name = "Energy drinks"}
            );

            modelBuilder.Entity<Product>().HasData(
                new Product
                {
                    Id = 1,
                    Name = "Espresso",
                    Price = 2.5m,
                    CategoryId = 1,
                    Image = ConvertImageToByteArray("espresso.jpg"),
                },
                new Product
                {
                    Id = 2,
                    Name = "Cappuccino",
                    Price = 3.0m,
                    CategoryId = 1,
                    Image = ConvertImageToByteArray("cappuccino.jpg"),
                },
                new Product
                {
                    Id = 3,
                    Name = "Latte",
                    Price = 3.20m,
                    CategoryId = 1,
                    Image = ConvertImageToByteArray("latte.jpg"),
                },
                new Product
                {
                    Id = 4,
                    Name = "Ice Coffee",
                    Price = 3.50m,
                    CategoryId = 2,
                    Image = ConvertImageToByteArray("icedcoffee.jpg"),
                },
                new Product
                {
                    Id = 5,
                    Name = "Cheesecake",
                    Price = 4.00m,
                    CategoryId = 3,
                    Image = ConvertImageToByteArray("cheesecake.jpg"),
                },
                new Product
                {
                    Id = 6,
                    Name = "Fanta",
                    Price = 3.00m,
                    CategoryId = 2,
                    Image = ConvertImageToByteArray("fanta.jpg"),
                },
                new Product
                {
                    Id = 7,
                    Name = "Red bull",
                    Price = 6.00m,
                    CategoryId = 4,
                    Image = ConvertImageToByteArray("red_bull.jpg"),
                }
             );

             modelBuilder.Entity<Table>().HasData(
                new Table { Id = 1, Number = 1, Capacity = 4, IsOccupied = false },
                new Table { Id = 2, Number = 2, Capacity = 2, IsOccupied = false },
                new Table { Id = 3, Number = 3, Capacity = 5, IsOccupied = false },
                new Table { Id = 4, Number = 4, Capacity = 10, IsOccupied = false },
                new Table { Id = 5, Number = 5, Capacity = 8, IsOccupied = false }
             );

             modelBuilder.Entity<Inventory>().HasData(
                new Inventory { Id = 1, ProductId = 1, Quantity = 10 },
                new Inventory { Id = 2, ProductId = 2, Quantity = 6 },
                new Inventory { Id = 3, ProductId = 3, Quantity =  5 },
                new Inventory { Id = 4, ProductId = 4, Quantity = 2 },
                new Inventory { Id = 5, ProductId = 5, Quantity = 4 },
                new Inventory { Id = 6, ProductId = 6, Quantity = 8 },
                new Inventory { Id = 7, ProductId = 7, Quantity = 3 }
             );

             modelBuilder.Entity<LoyaltyPoints>().HasData(
                new LoyaltyPoints { Id = 1, UserId = 2, Points = 51 },
                new LoyaltyPoints { Id = 2, UserId = 3, Points = 15 }
             );

            modelBuilder.Entity<Promotion>().HasData(
                new Promotion
                {
                    Id = 1,
                    Name = "Morning Coffee Deal",
                    Description = "10% off coffee products in the morning.",
                    DiscountPercent = 10,
                    StartDate = new DateTime(2026, 2, 1),
                    EndDate = new DateTime(2026, 2, 4),
                    TargetSegment = "ALL"
                },
                new Promotion
                {
                    Id = 2,
                    Name = "Dessert Weekend",
                    Description = "15% off desserts on weekends.",
                    DiscountPercent = 15,
                    StartDate = new DateTime(2026, 2, 3),
                    EndDate = new DateTime(2026, 2, 10),
                    TargetSegment = "VIP"
                }
           );

            modelBuilder.Entity<PromotionCategory>().HasData(
                new PromotionCategory { PromotionId = 1, CategoryId = 1 },
                new PromotionCategory { PromotionId = 2, CategoryId = 3 }
           );

            modelBuilder.Entity<Order>().HasData(
                new Order
                {
                    Id = 1,
                    UserId = 2,
                    TableId = 2,
                    OrderDate = new DateTime(2026, 2, 1, 10, 15, 0),
                    Status = "Paid",
                    TotalAmount = 14.00m
                },
                new Order
                {
                    Id = 2,
                    UserId = 3,
                    TableId = 1,
                    OrderDate = new DateTime(2026, 2, 2, 18, 45, 0),
                    Status = "Pending",
                    TotalAmount = 7.00m
                },
                new Order
                {
                    Id = 3,
                    UserId = 2,
                    TableId = 4,
                    OrderDate = new DateTime(2026, 1, 28, 12, 5, 0),
                    Status = "Paid",
                    TotalAmount = 9.20m
                },
                new Order
                {
                    Id = 4,
                    UserId = 2,
                    TableId = 5,
                    OrderDate = new DateTime(2026, 1, 28, 12, 5, 0),
                    Status = "Paid",
                    TotalAmount = 12.00m
                }
            );

            modelBuilder.Entity<OrderItem>().HasData(
                new OrderItem { Id = 1, OrderId = 1, ProductId = 1, Quantity = 4, Price = 2.50m },
                new OrderItem { Id = 2, OrderId = 1, ProductId = 5, Quantity = 1, Price = 4.00m },
                new OrderItem { Id = 3, OrderId = 2, ProductId = 4, Quantity = 2, Price = 3.50m },
                new OrderItem { Id = 4, OrderId = 3, ProductId = 3, Quantity = 1, Price = 3.20m },
                new OrderItem { Id = 5, OrderId = 3, ProductId = 6, Quantity = 1, Price = 3.00m },
                new OrderItem { Id = 6, OrderId = 3, ProductId = 2, Quantity = 1, Price = 3.00m },
                new OrderItem { Id = 7, OrderId = 4, ProductId = 7, Quantity = 2, Price = 6.00m }
            );

            modelBuilder.Entity<Payment>().HasData(
                new Payment
                {
                    Id = 1,
                    OrderId = 1,
                    Method = "Card",
                    Status = "Completed"
                },
                new Payment
                {
                    Id = 2,
                    OrderId = 3,
                    Method = "Card",
                    Status = "Completed"
                },
                new Payment
                {
                    Id = 3,
                    OrderId = 4,
                    Method = "Cash",
                    Status = "Completed"
                }
            );

            modelBuilder.Entity<Reservation>().HasData(
                new Reservation
                {
                    Id = 1,
                    UserId = 2,
                    TableId = 1,
                    ReservationDateTime = new DateTime(2026, 2, 5, 19, 0, 0),
                    NumberOfGuests = 2,
                    Status = "Confirmed"
                },
                new Reservation
                {
                    Id = 2,
                    UserId = 2,
                    TableId = 2,
                    ReservationDateTime = new DateTime(2026, 2, 6, 20, 30, 0),
                    NumberOfGuests = 4,
                    Status = "Pending"
                },
                new Reservation
                {
                    Id = 3,
                    UserId = 2,
                    TableId = 3,
                    ReservationDateTime = new DateTime(2026, 2, 6, 20, 30, 0),
                    NumberOfGuests = 4,
                    Status = "Cancelled"
                },
                new Reservation
                {
                    Id = 4,
                    UserId = 3,
                    TableId = 3,
                    ReservationDateTime = new DateTime(2026, 2, 7, 20, 30, 0),
                    NumberOfGuests = 4,
                    Status = "Confirmed"
                }
            );

            modelBuilder.Entity<Review>().HasData(
                new Review
                {
                    Id = 1,
                    UserId = 2,
                    ProductId = 1,
                    Rating = 5,
                    Comment = "Excellent espresso!",
                    DateCreated = new DateTime(2026, 2, 1)
                },
                new Review
                {
                    Id = 2,
                    UserId = 3,
                    ProductId = 4,
                    Rating = 4,
                    Comment = "Good, but I’d like a bit more ice.",
                    DateCreated = new DateTime(2026, 2, 2)
                },
                new Review
                {
                    Id = 3,
                    UserId = 2,
                    ProductId = 5,
                    Rating = 5,
                    Comment = "Cheesecake is great.",
                    DateCreated = new DateTime(2026, 1, 20)
                }
            );
        }
        private byte[] ConvertImageToByteArray(string fileName)
        {
            var basePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "images");
            var fullPath = Path.Combine(basePath, fileName);

            if (!File.Exists(fullPath))
                throw new FileNotFoundException($"File {fileName} not found in {fullPath}");

            return File.ReadAllBytes(fullPath);
        }
    }
}
