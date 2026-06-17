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
            modelBuilder.Entity<Reservation>().Property(r => r.DurationMinutes).HasDefaultValue(120);

            modelBuilder.Entity<Role>().HasData(
            new Role { Id = 1, Name = "Admin" },
            new Role { Id = 2, Name = "Mobile" }
            );

            modelBuilder.Entity<City>().HasData(
            new City { Id = 1, Name = "Sarajevo" },
            new City { Id = 2, Name = "Mostar" },
            new City { Id = 3, Name = "Tuzla" }
            );


            modelBuilder.Entity<Cafe>().HasData(
            new Cafe
            {
                Id = 1,
                Name = "CafeEase CVila",
                Address = "Bulevar Mese Selimovica 27",
                CityId = 1,
                Latitude = 43.8563,
                Longitude = 18.4131,
                PhoneNumber = "+38761111222",
                WorkingHours = "08:00 - 23:00",
                IsActive = true
            },
            new Cafe
            {
                Id = 2,
                Name = "CafeEase Bascarsija",
                Address = "Bravadziluk 8",
                CityId = 1,
                Latitude = 43.8595,
                Longitude = 18.4335,
                PhoneNumber = "+38761111333",
                WorkingHours = "08:00 - 22:00",
                IsActive = true
            },
            new Cafe
            {
                Id = 3,
                Name = "CafeEase SCC",
                Address = "Vrbanja 1",
                CityId = 1,
                Latitude = 43.8549,
                Longitude = 18.4033,
                PhoneNumber = "+38761111444",
                WorkingHours = "09:00 - 23:00",
                IsActive = true
            },
            new Cafe
            {
                Id = 4,
                Name = "CafeEase Mostar",
                Address = "Mostarskog bataljona 21",
                CityId = 2,
                Latitude = 43.3438,
                Longitude = 17.8078,
                PhoneNumber = "+38761111555",
                WorkingHours = "08:00 - 23:00",
                IsActive = true
            },
            new Cafe
            {
                Id = 5,
                Name = "CafeEase Tuzla",
                Address = "Marsala Tita 20",
                CityId = 3,
                Latitude = 44.5384,
                Longitude = 18.6671,
                PhoneNumber = "+38761111666",
                WorkingHours = "07:30 - 22:30",
                IsActive = true
            }
        );

            modelBuilder.Entity<User>().HasData(
             new User
             {
                 Id = 1,
                 FirstName = "Admin",
                 LastName = "Admin",
                 Username = "desktop",
                 Email = "admin@cafeease.com",
                 PasswordHash = "AQAAAAIAAYagAAAAEJT1QtIOmY1aSrSwIeWaINwZzjn35RyS0GQbD9qC0wVUK8FZiEzuclDXQqhHo+CoRA==",
                 PasswordSalt = "",
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
                 PasswordHash = "AQAAAAIAAYagAAAAED4pxuRPbplT7PbLPoZ64hDSBPBs4UdgfwxXh3F6hANY//m5HJF6GcGfa49iJS3l8Q==",
                 PasswordSalt = "",
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
                 PasswordHash = "AQAAAAIAAYagAAAAEBghbkX6f6PUzBg70Wf3y+LblqevZHipEpDtQ1e4wM9v8fERtivurUjnQVpzGXmi8w==",
                 PasswordSalt = "",
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
                    ImagePath = "espresso.jpg",
                },
                new Product
                {
                    Id = 2,
                    Name = "Cappuccino",
                    Price = 3.0m,
                    CategoryId = 1,
                    ImagePath ="cappuccino.jpg",
                },
                new Product
                {
                    Id = 3,
                    Name = "Latte",
                    Price = 3.20m,
                    CategoryId = 1,
                    ImagePath = "latte.jpg",
                },
                new Product
                {
                    Id = 4,
                    Name = "Ice Coffee",
                    Price = 3.50m,
                    CategoryId = 2,
                    ImagePath = "icedcoffee.jpg",
                },
                new Product
                {
                    Id = 5,
                    Name = "Cheesecake",
                    Price = 4.00m,
                    CategoryId = 3,
                    ImagePath = "cheesecake.jpg",
                },
                new Product
                {
                    Id = 6,
                    Name = "Fanta",
                    Price = 3.00m,
                    CategoryId = 2,
                    ImagePath = "fanta.jpg",
                },
                new Product
                {
                    Id = 7,
                    Name = "Red bull",
                    Price = 6.00m,
                    CategoryId = 4,
                    ImagePath = "red_bull.jpg",
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
                    StartDate = new DateTime(2026, 6, 25),
                    EndDate = new DateTime(2026, 6, 30),
                    TargetSegment = "NEW"
                },
                new Promotion
                {
                    Id = 2,
                    Name = "Dessert Weekend",
                    Description = "15% off desserts on weekends.",
                    DiscountPercent = 15,
                    StartDate = new DateTime(2026, 6, 5),
                    EndDate = new DateTime(2026, 6, 29),
                    TargetSegment = "ALL"
                },
                 new Promotion
                 {
                     Id = 3,
                     Name = "Cold Drinks Refresh Deal",
                     Description = "5% off cold drinks for VIP customers.",
                     DiscountPercent = 5,
                     StartDate = new DateTime(2026, 5, 7),
                     EndDate = new DateTime(2026, 5, 20),
                     TargetSegment = "VIP"
                 },
                new Promotion
                {
                    Id = 4,
                    Name = "CafeEase All Menu Discount",
                    Description = "5% off all menu categories for ALL customers.",
                    DiscountPercent = 5,
                    StartDate = new DateTime(2026, 6, 1),
                    EndDate = new DateTime(2026, 6, 30),
                    TargetSegment = "ALL"
                }
           );

            modelBuilder.Entity<PromotionCategory>().HasData(
                new PromotionCategory { PromotionId = 1, CategoryId = 1 },
                new PromotionCategory { PromotionId = 2, CategoryId = 3 },
                new PromotionCategory { PromotionId = 3, CategoryId = 2 },
                new PromotionCategory { PromotionId = 4, CategoryId = 1 },
                new PromotionCategory { PromotionId = 4, CategoryId = 2 },
                new PromotionCategory { PromotionId = 4, CategoryId = 3 },
                new PromotionCategory { PromotionId = 4, CategoryId = 4 }
           );

            modelBuilder.Entity<Order>().HasData(
                new Order
                {
                    Id = 1,
                    UserId = 2,
                    TableId = 2,
                    OrderDate = new DateTime(2026, 6, 1, 10, 15, 0),
                    Status = "Paid",
                    TotalAmount = 14.00m
                },
                new Order
                {
                    Id = 2,
                    UserId = 3,
                    TableId = 1,
                    OrderDate = new DateTime(2026, 6, 3, 18, 45, 0),
                    Status = "Pending",
                    TotalAmount = 7.00m
                },
                new Order
                {
                    Id = 3,
                    UserId = 2,
                    TableId = 4,
                    OrderDate = new DateTime(2026, 6, 7, 12, 5, 0),
                    Status = "Paid",
                    TotalAmount = 9.20m
                },
                new Order
                {
                    Id = 4,
                    UserId = 2,
                    TableId = 5,
                    OrderDate = new DateTime(2026, 6, 9, 12, 5, 0),
                    Status = "Paid",
                    TotalAmount = 12.00m
                },
                new Order
                {
                    Id = 5,
                    UserId = 3,
                    TableId = 3,
                    OrderDate = new DateTime(2026, 6, 10, 14, 30, 0),
                    Status = "Confirmed",
                    TotalAmount = 6.00m
                },
                new Order
                {
                    Id = 6,
                    UserId = 2,
                    TableId = 1,
                    OrderDate = new DateTime(2026, 6, 11, 16, 0, 0),
                    Status = "Completed",
                    TotalAmount = 3.50m
                }
            );

            modelBuilder.Entity<OrderItem>().HasData(
                new OrderItem { Id = 1, OrderId = 1, ProductId = 1, Quantity = 4, Price = 2.50m },
                new OrderItem { Id = 2, OrderId = 1, ProductId = 5, Quantity = 1, Price = 4.00m, Note = "Less sweet" },
                new OrderItem { Id = 3, OrderId = 2, ProductId = 4, Quantity = 2, Price = 3.50m },
                new OrderItem { Id = 4, OrderId = 3, ProductId = 3, Quantity = 1, Price = 3.20m },
                new OrderItem { Id = 5, OrderId = 3, ProductId = 6, Quantity = 1, Price = 3.00m },
                new OrderItem { Id = 6, OrderId = 3, ProductId = 2, Quantity = 1, Price = 3.00m , Size = "L", MilkType = "Oat", SugarLevel = 2, Note = "Extra hot"},
                new OrderItem { Id = 7, OrderId = 4, ProductId = 7, Quantity = 2, Price = 6.00m },
                new OrderItem { Id = 8, OrderId = 5, ProductId = 2, Quantity = 2, Price = 3.00m },
                new OrderItem { Id = 9, OrderId = 6, ProductId = 4, Quantity = 1, Price = 3.50m }
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
                },
                new Payment
                {
                    Id = 4,
                    OrderId = 5,
                    Method = "Cash",
                    Status = "Pending"
                },
                new Payment
                {
                    Id = 5,
                    OrderId = 6,
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
                    ReservationDateTime = new DateTime(2026, 6, 25, 19, 0, 0),
                    NumberOfGuests = 2,
                    Status = "Confirmed",
                    DurationMinutes = 120
                },
                new Reservation
                {
                    Id = 2,
                    UserId = 2,
                    TableId = 2,
                    ReservationDateTime = new DateTime(2026, 6, 25, 21, 0, 0),
                    NumberOfGuests = 2,
                    Status = "Pending",
                    DurationMinutes = 120
                },
                new Reservation
                {
                    Id = 3,
                    UserId = 2,
                    TableId = 3,
                    ReservationDateTime = new DateTime(2026, 6, 19, 18, 30, 0),
                    NumberOfGuests = 4,
                    Status = "Cancelled",
                    DurationMinutes = 120,
                    CancelledAt = new DateTime(2026, 6, 15, 12, 0, 0),
                    CancelledByUserId = 2,
                    CancellationReason = "Plans changed"
                },
                new Reservation
                {
                    Id = 4,
                    UserId = 3,
                    TableId = 3,
                    ReservationDateTime = new DateTime(2026, 6, 27, 21, 0, 0),
                    NumberOfGuests = 4,
                    Status = "Confirmed",
                    DurationMinutes = 120
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
                    DateCreated = new DateTime(2026, 4, 15)
                },
                new Review
                {
                    Id = 2,
                    UserId = 3,
                    ProductId = 4,
                    Rating = 4,
                    Comment = "Good, but I’d like a bit more ice.",
                    DateCreated = new DateTime(2026, 4, 18)
                },
                new Review
                {
                    Id = 3,
                    UserId = 2,
                    ProductId = 5,
                    Rating = 5,
                    Comment = "Cheesecake is great.",
                    DateCreated = new DateTime(2026, 5, 19)
                }
            );
        }
    }
}
