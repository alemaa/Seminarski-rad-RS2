using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace CafeEase.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddCafeSeed : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Cafes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Address = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CityId = table.Column<int>(type: "int", nullable: false),
                    Latitude = table.Column<double>(type: "float", nullable: false),
                    Longitude = table.Column<double>(type: "float", nullable: false),
                    PhoneNumber = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    WorkingHours = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Cafes", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Cafes_Cities_CityId",
                        column: x => x.CityId,
                        principalTable: "Cities",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.InsertData(
                table: "Cafes",
                columns: new[] { "Id", "Address", "CityId", "IsActive", "Latitude", "Longitude", "Name", "PhoneNumber", "WorkingHours" },
                values: new object[,]
                {
                    { 1, "Titova 12", 1, true, 43.856299999999997, 18.4131, "CafeEase Centar", "+38761111222", "08:00 - 23:00" },
                    { 2, "Bravadziluk 8", 1, true, 43.859499999999997, 18.433499999999999, "CafeEase Bascarsija", "+38761111333", "08:00 - 22:00" },
                    { 3, "Vrbanja 1", 1, true, 43.854900000000001, 18.403300000000002, "CafeEase SCC", "+38761111444", "09:00 - 23:00" },
                    { 4, "Mostarskog bataljona 21", 2, true, 43.343800000000002, 17.8078, "CafeEase Mostar", "+38761111555", "08:00 - 23:00" },
                    { 5, "Marsala Tita 20", 3, true, 44.538400000000003, 18.667100000000001, "CafeEase Tuzla", "+38761111666", "07:30 - 22:30" }
                });

            migrationBuilder.CreateIndex(
                name: "IX_Cafes_CityId",
                table: "Cafes",
                column: "CityId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Cafes");
        }
    }
}
