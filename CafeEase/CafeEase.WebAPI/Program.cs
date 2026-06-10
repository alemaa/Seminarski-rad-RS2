using AutoMapper;
using CafeEase.Services;
using CafeEase.Services.Database;
using CafeEase.Services.Mapping;
using CafeEase.WebAPI.Authentication;
using CafeEase.WebAPI.Filters;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddDbContext<CafeEaseDbContext>(options => options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddHttpContextAccessor();
builder.Services.AddHttpClient();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<ICategoryService, CategoryService>();
builder.Services.AddScoped<IProductService, ProductService>();
builder.Services.AddScoped<IOrderService, OrderService>();
builder.Services.AddScoped<IOrderItemService, OrderItemService>();
builder.Services.AddScoped<IPaymentService, PaymentService>();
builder.Services.AddScoped<ILoyaltyPointsService, LoyaltyPointsService>();
builder.Services.AddScoped<IPromotionService, PromotionService>();
builder.Services.AddScoped<IReviewService, ReviewService>();
builder.Services.AddScoped<IReservationService, ReservationService>();
builder.Services.AddScoped<IRecommendationService, RecommendationService>();
builder.Services.AddScoped<ITableService, TableService>();
builder.Services.AddScoped<IInventoryService, InventoryService>();   
builder.Services.AddScoped<ICityService, CityService>();
builder.Services.AddScoped<IStripePaymentService, StripePaymentService>();
builder.Services.AddScoped<INotificationService, NotificationService>();
builder.Services.AddScoped<ICafeService, CafeService>();

builder.Services.AddControllers(options =>
{
    options.Filters.Add<ExceptionFilter>();
})
.ConfigureApiBehaviorOptions(options =>
{
    options.InvalidModelStateResponseFactory = context =>
    {
        var errors = context.ModelState
            .Where(x => x.Value?.Errors.Count > 0)
            .SelectMany(x => x.Value!.Errors.Select(e => e.ErrorMessage))
            .Where(x => !string.IsNullOrWhiteSpace(x))
            .ToList();

        return new BadRequestObjectResult(new
        {
            errors = new Dictionary<string, string[]>
            {
                ["userError"] = errors.ToArray()
            }
        });
    };
});

builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("Basic", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "basic",
        Description = "Basic Authentication"
    });

    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
    {
        {
            new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Reference = new Microsoft.OpenApi.Models.OpenApiReference
                {
                    Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                    Id = "Basic"
                }
            },
            new string[] {}
        }
    });
});

builder.Services.AddAuthentication("BasicAuthentication")
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

builder.Services.AddAutoMapper(cfg =>
{
    cfg.ShouldMapMethod = methodInfo => false;
}, typeof(MappingProfile));

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowSpecificOrigin",
        builder => builder.AllowAnyOrigin() 
                          .AllowAnyHeader()
                          .AllowAnyMethod());
});

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var dataContext = scope.ServiceProvider.GetRequiredService<CafeEaseDbContext>();

    var databaseExist = dataContext.Database.GetService<IRelationalDatabaseCreator>().Exists();

    if (!databaseExist)
    {
        dataContext.Database.Migrate();

        var recommendResutService = scope.ServiceProvider.GetRequiredService<IRecommendationService>();
        try
        {
            await Task.Delay(5000);
           await recommendResutService.TrainModel();
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Training failed: {ex.Message}");
        }
    }
}


// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}


app.UseStaticFiles();

app.UseHttpsRedirection();

app.UseCors("AllowSpecificOrigin");

app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();

app.Run();
