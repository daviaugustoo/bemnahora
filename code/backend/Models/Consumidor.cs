using MongoDB.Bson.Serialization.Attributes;

namespace BemNaHoraAPI.Models;

[BsonDiscriminator("Consumidor")]
public class Consumidor : Usuario
{
    [BsonElement("enderecoPrincipal")]
    public string? EnderecoPrincipal { get; set; }
    
    [BsonElement("CPF")]
    public string? CPF { get; set; }
}
