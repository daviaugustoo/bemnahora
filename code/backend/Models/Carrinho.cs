using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace BemNaHoraAPI.Models
{
    public class Carrinho
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string? Id { get; set; }

        [BsonElement("itens")]
        public List<ItemCarrinho> Itens { get; set; } = new();

        [BsonIgnore]
        public double Total => Itens.Sum(i => i.Subtotal);
    }
}
