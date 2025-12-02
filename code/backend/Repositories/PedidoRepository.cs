using BemNaHoraAPI.Interfaces;
using BemNaHoraAPI.Models;
using MongoDB.Driver;

namespace BemNaHoraAPI.Repositories
{
    public class PedidoRepository : MongoRepository<Pedido>, IPedidoRepository
    {
        public PedidoRepository(IMongoDatabase database)
            : base(database, "pedidos") { }

        public List<Pedido> GetByData(DateTime data) =>
            Collection.Find(p => p.DataPedido.Date == data.Date).ToList();

        public List<Pedido> GetByPeriodo(DateTime inicio, DateTime fim) =>
            Collection.Find(p => p.DataPedido >= inicio && p.DataPedido <= fim).ToList();
    }
}
