using BemNaHoraAPI.Interfaces;
using BemNaHoraAPI.Models;
using MongoDB.Driver;

namespace BemNaHoraAPI.Repositories
{
    public class EntregaRepository : MongoRepository<Entrega>, IEntregaRepository
    {
        public EntregaRepository(IMongoDatabase database)
            : base(database, "entregas")
        {
        }

        public List<Entrega> GetByEntregador(string entregadorId) =>
            Collection.Find(e => e.EntregadorId == entregadorId).ToList();

        public List<Entrega> GetByDistribuidora(string distribuidoraId) =>
            Collection.Find(e => e.DistribuidoraId == distribuidoraId).ToList();

        public List<Entrega> GetByConsumidor(string consumidorId) =>
            Collection.Find(e => e.ConsumidorId == consumidorId).ToList();

        public List<Entrega> GetByStatus(StatusEntrega status) =>
            Collection.Find(e => e.Status == status).ToList();

        public List<Entrega> GetByPeriodo(DateTime inicio, DateTime fim) =>
            Collection.Find(e => e.DataCriacao >= inicio && e.DataCriacao <= fim).ToList();
    }
}
