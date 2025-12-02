using BemNaHoraAPI.Models;

namespace BemNaHoraAPI.Interfaces
{
    public interface IPedidoRepository : IRepository<Pedido>
    {
        List<Pedido> GetByData(DateTime data);
        List<Pedido> GetByPeriodo(DateTime inicio, DateTime fim);
    }
}
