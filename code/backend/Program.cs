using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using bemnahora.Models;                // MongoDbSettings
using MongoDB.Driver;
using MercadoPago.Config;

// NOVOS usings p/ Repository Pattern
using BemNaHoraAPI.Interfaces;
using BemNaHoraAPI.Repositories;
using BemNaHoraAPI.Services;
using BemNaHoraAPI.Hubs;
using Microsoft.Azure.SignalR;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddCors(options =>
{
    options.AddPolicy("CORS",
        policy =>
        {
            policy
                .AllowAnyOrigin()
                .AllowAnyMethod()
                .AllowAnyHeader();
        });
});
// ===== MongoDB =====
var mongoSettings = builder.Configuration.GetSection("MongoDB").Get<MongoDbSettings>();
if (mongoSettings == null || string.IsNullOrEmpty(mongoSettings.ConnectionString) || string.IsNullOrEmpty(mongoSettings.DatabaseName))
{
    throw new InvalidOperationException("As configs do MongoDB não estão feitas corretamente.");
}
builder.Services.AddSingleton<IMongoClient>(new MongoClient(mongoSettings.ConnectionString));
builder.Services.AddSingleton(serviceProvider =>
{
    var client = serviceProvider.GetRequiredService<IMongoClient>();
    return client.GetDatabase(mongoSettings.DatabaseName);
});

// ===== JWT =====
var jwtConfig = builder.Configuration.GetSection("Jwt");
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new()
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtConfig["Issuer"],
            ValidAudience = jwtConfig["Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(jwtConfig["Key"]!))
        };
    });

builder.Services.AddAuthorization();
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddOpenApi();
builder.Services.AddSignalR()
    .AddJsonProtocol()
    .AddAzureSignalR(builder.Configuration["AzureSignalR:ConnectionString"]);



// ===== Repository Pattern =====
// === Repositories ===
builder.Services.AddSingleton<IUsuarioRepository, UsuarioRepository>();
builder.Services.AddSingleton<IProdutoRepository, ProdutoRepository>();
builder.Services.AddSingleton<ICarrinhoRepository, CarrinhoRepository>();
builder.Services.AddSingleton<IPedidoRepository, PedidoRepository>();
builder.Services.AddSingleton<IEntregaRepository, EntregaRepository>();
builder.Services.AddSingleton<IChatRepository, ChatRepository>();
builder.Services.AddSingleton<ILocalizacaoRepository, LocalizacaoRepository>();

// === Services ===
builder.Services.AddSingleton<UsuarioService>();
builder.Services.AddSingleton<ProdutoService>();
builder.Services.AddSingleton<CarrinhoService>();
builder.Services.AddSingleton<PedidoService>();
builder.Services.AddSingleton<EntregaService>();
builder.Services.AddSingleton<PagamentoService>();
builder.Services.AddSingleton<ChatService>();
builder.Services.AddSingleton<OpenStreetMapService>();


var accessToken = builder.Configuration["MercadoPago:AccessToken"];
MercadoPagoConfig.AccessToken = accessToken;
var app = builder.Build();

app.UseCors("CORS");
app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();
app.UseStaticFiles();
app.MapControllers();
app.UseAzureSignalR(routes =>
{
    routes.MapHub<ChatHub>("/hubs/chat");
});
app.UseSwagger();
app.UseSwaggerUI();
app.MapOpenApi();


app.Run();
