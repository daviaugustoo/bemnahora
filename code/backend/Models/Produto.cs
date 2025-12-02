using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System.Text.Json.Serialization;

namespace BemNaHoraAPI.Models
{
    public class Produto
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string? Id { get; set; }

        [BsonElement("nome")]
        public string Nome { get; set; } = null!;

        [BsonElement("descricao")]
        public string? Descricao { get; set; }

        [BsonElement("preco")]
        public double Preco { get; set; }

        [BsonElement("imagem")]
        public string? Imagem { get; set; }  

        [BsonElement("categoria")]
        [BsonRepresentation(BsonType.String)]
        public CategoriaProduto Categoria { get; set; }

        [BsonElement("peso")]
        public string? Peso { get; set; }

        [BsonElement("unidade")]
        public string? Unidade { get; set; }

        [BsonElement("quantidadeEstoque")]
        public int QuantidadeEmEstoque { get; set; }

        [BsonElement("createdAt")]
        public DateTime? CreatedAt { get; set; }

        [BsonElement("updatedAt")]
        public DateTime? UpdatedAt { get; set; }
        
        [BsonElement("imagemUrl")]
        public string? ImagemUrl { get; set; }
    }
    [JsonConverter(typeof(JsonStringEnumConverter))]
        public enum CategoriaProduto
        {
            churrasco,
            bebida,
            carne
        }
}
