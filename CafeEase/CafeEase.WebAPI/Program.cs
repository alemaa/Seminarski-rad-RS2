using AutoMapper;
using CafeEase.Services;
using CafeEase.Services.Database;
using CafeEase.Services.Mapping;
using CafeEase.WebAPI.Filters;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddDbContext<CafeEaseDbContext>(options => options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<ICategoryService, CategoryService>();
builder.Services.AddTransient<IProductService, ProductService>();
builder.Services.AddTransient<IOrderService, OrderService>();
builder.Services.AddTransient<IOrderItemService, OrderItemService>();
builder.Services.AddTransient<IPaymentService, PaymentService>();
builder.Services.AddTransient<ILoyaltyPointsService, LoyaltyPointsService>();
builder.Services.AddTransient<IPromotionService, PromotionService>();
builder.Services.AddTransient<IReviewService, ReviewService>();
builder.Services.AddTransient<IReservationService, ReservationService>();


builder.Services.AddControllers(options =>
{
    options.Filters.Add<ExceptionFilter>();
});

builder.Services.AddAutoMapper(cfg =>
{
    cfg.ShouldMapMethod = methodInfo => false;
}, typeof(MappingProfile));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
