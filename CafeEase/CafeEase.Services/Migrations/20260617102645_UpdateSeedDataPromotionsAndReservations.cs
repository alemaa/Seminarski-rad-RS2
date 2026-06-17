using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace CafeEase.Services.Migrations
{
    /// <inheritdoc />
    public partial class UpdateSeedDataPromotionsAndReservations : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "PromotionCategories",
                columns: new[] { "CategoryId", "PromotionId" },
                values: new object[] { 2, 3 });

            migrationBuilder.UpdateData(
                table: "Promotions",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "StartDate", "TargetSegment" },
                values: new object[] { new DateTime(2026, 6, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "NEW" });

            migrationBuilder.UpdateData(
                table: "Promotions",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "EndDate", "TargetSegment" },
                values: new object[] { new DateTime(2026, 6, 29, 0, 0, 0, 0, DateTimeKind.Unspecified), "ALL" });

            migrationBuilder.UpdateData(
                table: "Promotions",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "Description", "Name" },
                values: new object[] { "5% off cold drinks for VIP customers.", "Cold Drinks Refresh Deal" });

            migrationBuilder.InsertData(
                table: "Promotions",
                columns: new[] { "Id", "Description", "DiscountPercent", "EndDate", "Name", "StartDate", "TargetSegment" },
                values: new object[] { 4, "5% off all menu categories for ALL customers.", 5.0, new DateTime(2026, 6, 30, 0, 0, 0, 0, DateTimeKind.Unspecified), "CafeEase All Menu Discount", new DateTime(2026, 6, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "ALL" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "DurationMinutes", "ReservationDateTime" },
                values: new object[] { 120, new DateTime(2026, 6, 25, 19, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 2,
                column: "ReservationDateTime",
                value: new DateTime(2026, 6, 25, 21, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CancelledAt", "DurationMinutes", "ReservationDateTime" },
                values: new object[] { new DateTime(2026, 6, 15, 12, 0, 0, 0, DateTimeKind.Unspecified), 120, new DateTime(2026, 6, 19, 18, 30, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "DurationMinutes", "ReservationDateTime" },
                values: new object[] { 120, new DateTime(2026, 6, 27, 21, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.InsertData(
                table: "PromotionCategories",
                columns: new[] { "CategoryId", "PromotionId" },
                values: new object[,]
                {
                    { 1, 4 },
                    { 2, 4 },
                    { 3, 4 },
                    { 4, 4 }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "PromotionCategories",
                keyColumns: new[] { "CategoryId", "PromotionId" },
                keyValues: new object[] { 2, 3 });

            migrationBuilder.DeleteData(
                table: "PromotionCategories",
                keyColumns: new[] { "CategoryId", "PromotionId" },
                keyValues: new object[] { 1, 4 });

            migrationBuilder.DeleteData(
                table: "PromotionCategories",
                keyColumns: new[] { "CategoryId", "PromotionId" },
                keyValues: new object[] { 2, 4 });

            migrationBuilder.DeleteData(
                table: "PromotionCategories",
                keyColumns: new[] { "CategoryId", "PromotionId" },
                keyValues: new object[] { 3, 4 });

            migrationBuilder.DeleteData(
                table: "PromotionCategories",
                keyColumns: new[] { "CategoryId", "PromotionId" },
                keyValues: new object[] { 4, 4 });

            migrationBuilder.DeleteData(
                table: "Promotions",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.UpdateData(
                table: "Promotions",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "StartDate", "TargetSegment" },
                values: new object[] { new DateTime(2026, 6, 20, 0, 0, 0, 0, DateTimeKind.Unspecified), "ALL" });

            migrationBuilder.UpdateData(
                table: "Promotions",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "EndDate", "TargetSegment" },
                values: new object[] { new DateTime(2026, 6, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "NEW" });

            migrationBuilder.UpdateData(
                table: "Promotions",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "Description", "Name" },
                values: new object[] { "5% off hot drinks during winter season.", "Winter Coffee Special" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "DurationMinutes", "ReservationDateTime" },
                values: new object[] { 90, new DateTime(2026, 6, 18, 19, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 2,
                column: "ReservationDateTime",
                value: new DateTime(2026, 6, 18, 20, 30, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CancelledAt", "DurationMinutes", "ReservationDateTime" },
                values: new object[] { new DateTime(2026, 6, 19, 12, 0, 0, 0, DateTimeKind.Unspecified), 60, new DateTime(2026, 6, 20, 18, 30, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "DurationMinutes", "ReservationDateTime" },
                values: new object[] { 180, new DateTime(2026, 6, 25, 21, 0, 0, 0, DateTimeKind.Unspecified) });
        }
    }
}
