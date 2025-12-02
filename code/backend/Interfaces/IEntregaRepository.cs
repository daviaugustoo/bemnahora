using BemNaHoraAPI.Models;

namespace BemNaHoraAPI.Interfaces
{
    public interface IEntregaRepository : IRepository<Entrega>
    {
        List<Entrega> GetByEntregador(string entregadorId);
        List<Entrega> GetByDistribuidora(string distribuidoraId);
        List<Entrega> GetByConsumidor(string consumidorId);
        List<Entrega> GetByStatus(StatusEntrega status);
        List<Entrega> GetByPeriodo(DateTime inicio, DateTime fim);
    }
}
