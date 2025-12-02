using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace BemNaHoraAPI.Models;

public class ChatMessage
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string? Id { get; set; }

    [BsonElement("pedidoId")]
    public string PedidoId { get; set; } = null!;

    [BsonElement("remetenteId")]
    public string RemetenteId { get; set; } = null!; // Usuario.Id

    [BsonElement("remetenteTipo")]
    public string RemetenteTipo { get; set; } = null!; // "Distribuidora" | "Entregador" | "Consumidor"

    [BsonElement("texto")]
    public string Texto { get; set; } = null!;

    [BsonElement("enviadoEmUtc")]
    public DateTime EnviadoEmUtc { get; set; } = DateTime.UtcNow;
}
