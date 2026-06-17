using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CafeEase.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddPendingPaymentSeed : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Payments",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "Method", "OrderId", "Status" },
                values: new object[] { "Cash", 2, "Pending" });

            migrationBuilder.UpdateData(
                table: "Payments",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "Method", "OrderId" },
                values: new object[] { "Card", 3 });

            migrationBuilder.UpdateData(
                table: "Payments",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "OrderId", "Status" },
                values: new object[] { 4, "Completed" });

            migrationBuilder.UpdateData(
                table: "Payments",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "OrderId", "Status" },
                values: new object[] { 5, "Pending" });

            migrationBuilder.InsertData(
                table: "Payments",
                columns: new[] { "Id", "Method", "OrderId", "ProviderIntentId", "Status" },
                values: new object[] { 6, "Cash", 6, null, "Completed" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Payments",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.UpdateData(
                table: "Payments",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "Method", "OrderId", "Status" },
                values: new object[] { "Card", 3, "Completed" });

            migrationBuilder.UpdateData(
                table: "Payments",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "Method", "OrderId" },
                values: new object[] { "Cash", 4 });

            migrationBuilder.UpdateData(
                table: "Payments",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "OrderId", "Status" },
                values: new object[] { 5, "Pending" });

            migrationBuilder.UpdateData(
                table: "Payments",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "OrderId", "Status" },
                values: new object[] { 6, "Completed" });
        }
    }
}
