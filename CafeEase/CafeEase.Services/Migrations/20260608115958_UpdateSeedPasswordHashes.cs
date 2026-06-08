using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CafeEase.Services.Migrations
{
    /// <inheritdoc />
    public partial class UpdateSeedPasswordHashes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "PasswordHash", "PasswordSalt" },
                values: new object[] { "AQAAAAIAAYagAAAAEJT1QtIOmY1aSrSwIeWaINwZzjn35RyS0GQbD9qC0wVUK8FZiEzuclDXQqhHo+CoRA==", "" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "PasswordHash", "PasswordSalt" },
                values: new object[] { "AQAAAAIAAYagAAAAED4pxuRPbplT7PbLPoZ64hDSBPBs4UdgfwxXh3F6hANY//m5HJF6GcGfa49iJS3l8Q==", "" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "PasswordHash", "PasswordSalt" },
                values: new object[] { "AQAAAAIAAYagAAAAEBghbkX6f6PUzBg70Wf3y+LblqevZHipEpDtQ1e4wM9v8fERtivurUjnQVpzGXmi8w==", "" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "PasswordHash", "PasswordSalt" },
                values: new object[] { "L0uD9aDjQiZ6US9mT63C+tMvcSk=", "js30TX4cHnStZnZM8pWbcg==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "PasswordHash", "PasswordSalt" },
                values: new object[] { "w6NEGcaz3XwZej0uJcY1mJIWrAI=", "tNcmHa/vi33ilAmQImsPhg==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "PasswordHash", "PasswordSalt" },
                values: new object[] { "dlKlLumk23Dx2D3OgAiBbZsFmfo=", "ym5obohaOyqCOlyuhaGxGQ==" });
        }
    }
}
