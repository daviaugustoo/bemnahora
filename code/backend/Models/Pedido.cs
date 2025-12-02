using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace BemNaHoraAPI.Models
{
    public enum StatusPedido
    {
        Pendente,
        Pago,
        Enviado,
        Cancelado
    }

    public class Pedido
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string? Id { get; set; }

        [BsonElement("carrinho")]
        public required Carrinho Carrinho { get; set; }

        [BsonElement("valorFrete")]
        public double ValorFrete { get; set; }

        [BsonElement("valorTotal")]
        public double ValorTotal { get; set; }

        [BsonElement("dataPedido")]
        public DateTime DataPedido { get; set; } = DateTime.Now;

        [BsonElement("status")]
        public StatusPedido Status { get; set; } = StatusPedido.Pendente;
    }
}
