using MongoDB.Bson.Serialization.Attributes;

namespace BemNaHoraAPI.Models;

[BsonDiscriminator("Entregador")]
public class Entregador : Usuario
{
    [BsonElement("cnh")]
    public string Cnh { get; set; } = null!;

    [BsonElement("disponivel")]
    public bool Disponivel { get; set; }
}
