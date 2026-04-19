using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CafeEase.Services.Migrations
{
    /// <inheritdoc />
    public partial class UpdateReservationSeedDates : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 1,
                column: "ReservationDateTime",
                value: new DateTime(2026, 4, 21, 19, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 2,
                column: "ReservationDateTime",
                value: new DateTime(2026, 4, 22, 20, 30, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 3,
                column: "ReservationDateTime",
                value: new DateTime(2026, 4, 24, 18, 30, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 4,
                column: "ReservationDateTime",
                value: new DateTime(2026, 4, 26, 21, 0, 0, 0, DateTimeKind.Unspecified));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 1,
                column: "ReservationDateTime",
                value: new DateTime(2026, 2, 5, 19, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 2,
                column: "ReservationDateTime",
                value: new DateTime(2026, 2, 6, 20, 30, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 3,
                column: "ReservationDateTime",
                value: new DateTime(2026, 2, 6, 20, 30, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 4,
                column: "ReservationDateTime",
                value: new DateTime(2026, 2, 7, 20, 30, 0, 0, DateTimeKind.Unspecified));
        }
    }
}
