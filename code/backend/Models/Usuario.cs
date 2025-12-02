using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace BemNaHoraAPI.Models;

[BsonDiscriminator(RootClass = true)]

[BsonKnownTypes(typeof(Entregador), typeof(Consumidor), typeof(Distribuidora))]
public class Usuario
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string? Id { get; set; }

    [BsonElement("passwordHash")]
    public string PasswordHash { get; set; } = null!;

    [BsonElement("username")]
    public string Username { get; set; } = null!;

    // para retornar qual o tipo do usuario em buscas
    [BsonIgnore]
    public string TipoUsuario => GetType().Name;

}
