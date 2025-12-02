using BemNaHoraAPI.Interfaces;
using BemNaHoraAPI.Models;

namespace BemNaHoraAPI.Services
{
    public class PedidoService
    {
        private readonly IPedidoRepository _repo;

        public PedidoService(IPedidoRepository repo)
        {
            _repo = repo;
        }

        public List<Pedido> GetAll() => _repo.GetAll();

        public Pedido? GetById(string id) => _repo.GetById(id);

        public void Create(Pedido pedido)
        {
            pedido.ValorTotal = pedido.Carrinho.Total;
            _repo.Insert(pedido);
        }

        public bool Update(string id, Pedido pedido)
        {
            pedido.Id = id;
            return _repo.Replace(id, pedido);
        }

        public bool Delete(string id) => _repo.Delete(id);

        public void AlterarStatus(string pedidoId, StatusPedido novoStatus)
        {
            var pedido = _repo.GetById(pedidoId) ?? throw new Exception("Pedido não encontrado.");
            pedido.Status = novoStatus;
            _repo.Replace(pedidoId, pedido);
        }

        public bool ProcessarPagamento(string pedidoId, Func<double, bool> apiPagamento)
        {
            var pedido = _repo.GetById(pedidoId) ?? throw new Exception("Pedido não encontrado.");
            var resultado = apiPagamento(pedido.ValorTotal + pedido.ValorFrete);
            if (resultado)
            {
                pedido.Status = StatusPedido.Pago;
                _repo.Replace(pedidoId, pedido);
            }
            return resultado;
        }
    }
}
