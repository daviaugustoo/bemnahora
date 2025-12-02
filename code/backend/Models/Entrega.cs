using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace BemNaHoraAPI.Models
{
     public enum StatusEntrega
    {
        Criada,
        AguardandoRetirada,
        EmTransito,
        Entregue,
        Cancelada
    }

    public class Entrega
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string? Id { get; set; }

        // Relação com o Pedido (1 entrega para 1 pedido)
        [BsonElement("pedidoId")]
        public string PedidoId { get; set; } = null!;

        // Quem vai entregar (Entregador : Usuario)
        [BsonElement("entregadorId")]
        public string EntregadorId { get; set; } = null!;

        // De qual distribuidora está saindo (Distribuidora : Usuario)
        [BsonElement("distribuidoraId")]
        public string DistribuidoraId { get; set; } = null!;

        // Para qual consumidor (Consumidor : Usuario)
        [BsonElement("consumidorId")]
        public string ConsumidorId { get; set; } = null!;

        // Endereço de entrega (pode vir do consumidor ou ser sobrescrito)
        [BsonElement("enderecoEntrega")]
        public string EnderecoEntrega { get; set; } = null!;

        [BsonElement("status")]
        [BsonRepresentation(BsonType.String)]
        public StatusEntrega Status { get; set; } = StatusEntrega.Criada;

        // Datas importantes
        [BsonElement("dataCriacao")]
        public DateTime DataCriacao { get; set; } = DateTime.UtcNow;

        [BsonElement("dataPrevista")]
        public DateTime? DataPrevista { get; set; }

        [BsonElement("dataEntrega")]
        public DateTime? DataEntrega { get; set; }
       
    }
}
