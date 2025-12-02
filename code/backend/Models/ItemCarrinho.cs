using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace BemNaHoraAPI.Models
{
    public class ItemCarrinho
    {
        // opcional: id do produto (armazenado como ObjectId no Mongo)
        [BsonElement("produtoId")]
        [BsonRepresentation(BsonType.ObjectId)]
        public string? ProdutoId { get; set; }

        // opcional: snapshot do produto (pode ser preenchido ao adicionar o item)
        [BsonElement("produto")]
        public Produto? Produto { get; set; }

        [BsonElement("quantidade")]
        public int Quantidade { get; set; }

        // preço unitário armazenado no item para manter histórico caso o preço do produto mude
        [BsonElement("precoUnitario")]
        public double PrecoUnitario { get; set; }

        [BsonIgnore]
        public double Subtotal => PrecoUnitario * Quantidade;
    }
}
