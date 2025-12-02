using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace BemNaHoraAPI.Models
{
    public class Localizacao
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string? Id { get; set; }

        public string UsuarioId { get; set; } = string.Empty;
        public string Endereco { get; set; } = string.Empty;
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public DateTime DataCriacao { get; set; } = DateTime.UtcNow;
    }

    public class EnderecoGeocodificado
    {
        public string EnderecoFormatado { get; set; } = string.Empty;
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public string Pais { get; set; } = string.Empty;
        public string Estado { get; set; } = string.Empty;
        public string Cidade { get; set; } = string.Empty;
        public string CEP { get; set; } = string.Empty;
        public string Bairro { get; set; } = string.Empty;
        public string Rua { get; set; } = string.Empty;
    }

    public class RotaResponse
    {
        public double DistanciaKm { get; set; }
        public int DuracaoMinutos { get; set; }
        public List<Coordenada> Coordenadas { get; set; } = new();
    }

    public class Coordenada
    {
        public double Latitude { get; set; }
        public double Longitude { get; set; }
    }
}
