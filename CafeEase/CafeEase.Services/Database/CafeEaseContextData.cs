using CafeEase.Model;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
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
                 CityId = 2,
             }
            );

            modelBuilder.Entity<Category>().HasData(
                new Category { Id = 1, Name = "Coffee" },
                new Category { Id = 2, Name = "Cold Drinks" },
                new Category { Id = 3, Name = "Desserts" }
            );

            modelBuilder.Entity<Product>().HasData(
                new Product
                {
                    Id = 1,
                    Name = "Espresso",
                    Price = 2.5m,
                    CategoryId = 1
                },
                new Product
                {
                    Id = 2,
                    Name = "Cappuccino",
                    Price = 3.0m,
                    CategoryId = 1
                },
                new Product
                {
                    Id = 3,
                    Name = "Latte",
                    Price = 3.20m,
                    CategoryId = 1
                },
                new Product
                {
                    Id = 4,
                    Name = "Ice Coffee",
                    Price = 3.50m,
                    CategoryId = 2
                },
                new Product
                {
                    Id = 5,
                    Name = "Cheesecake",
                    Price = 4.00m,
                    CategoryId = 3
                }
             );

             modelBuilder.Entity<Table>().HasData(
                new Table { Id = 1, Number = 1, Capacity = 4, IsOccupied = false },
                new Table { Id = 2, Number = 2, Capacity = 2, IsOccupied = false },
                new Table { Id = 3, Number = 3, Capacity = 5, IsOccupied = false }
             );

             modelBuilder.Entity<Inventory>().HasData(
                new Inventory { Id = 1, ProductId = 1, Quantity = 100 },
                new Inventory { Id = 2, ProductId = 2, Quantity = 80 }
             );

             modelBuilder.Entity<LoyaltyPoints>().HasData(
                new LoyaltyPoints { Id = 1, UserId = 2, Points = 0 }
             );


        }
    }
}
