using MongoDB.Bson.Serialization.Attributes;

namespace BemNaHoraAPI.Models;

[BsonDiscriminator("Distribuidora")]
public class Distribuidora : Usuario
{
    [BsonElement("nomeFantasia")]
    public string NomeFantasia { get; set; } = null!;

    [BsonElement("cnpj")]
    public string Cnpj { get; set; } = null!;
}
