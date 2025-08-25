using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "OrderService API",
        Version = "v1"
    });
});

var app = builder.Build();

// Always enable Swagger
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "OrderService API V1");
    c.RoutePrefix = "swagger";
});

app.UseHttpsRedirection();
app.UseAuthorization();

app.MapControllers();

// ✅ Root redirect
app.MapGet("/", () => Results.Redirect("/swagger"));

// ✅ New Info endpoint
app.MapGet("/api/info", () =>
    Results.Json(new { Service = "OrderService", Version = "1.0.1", Timestamp = DateTime.UtcNow })
);

app.Run();
