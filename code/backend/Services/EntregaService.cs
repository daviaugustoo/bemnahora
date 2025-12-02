using BemNaHoraAPI.Interfaces;
using BemNaHoraAPI.Models;

namespace BemNaHoraAPI.Services
{
    public class EntregaService
    {
        private readonly IEntregaRepository _repo;

        public EntregaService(IEntregaRepository repo)
        {
            _repo = repo;
        }

        // CRUD básico
        public List<Entrega> GetAll() => _repo.GetAll();

        public Entrega? GetById(string id) => _repo.GetById(id);

        public void Create(Entrega entrega)
        {
            entrega.DataCriacao = DateTime.UtcNow;

            // Se já vier com DataPrevista, ok. Se quiser, pode calcular aqui.
            _repo.Insert(entrega);
        }

        public bool Update(string id, Entrega entrega)
        {
            entrega.Id = id;
            return _repo.Replace(id, entrega);
        }

        public bool Delete(string id) => _repo.Delete(id);

        // Regras de negócio

        public void AlterarStatus(string entregaId, StatusEntrega novoStatus)
        {
            var entrega = _repo.GetById(entregaId) ?? throw new Exception("Entrega não encontrada.");

            entrega.Status = novoStatus;
            if (novoStatus == StatusEntrega.Entregue)
            {
                entrega.DataEntrega = DateTime.UtcNow;
            }

            _repo.Replace(entregaId, entrega);
        }

        public List<Entrega> GetByEntregador(string entregadorId) =>
            _repo.GetByEntregador(entregadorId);

        public List<Entrega> GetByDistribuidora(string distribuidoraId) =>
            _repo.GetByDistribuidora(distribuidoraId);

        public List<Entrega> GetByConsumidor(string consumidorId) =>
            _repo.GetByConsumidor(consumidorId);

        public List<Entrega> GetByStatus(StatusEntrega status) =>
            _repo.GetByStatus(status);

        public List<Entrega> GetByPeriodo(DateTime inicio, DateTime fim) =>
            _repo.GetByPeriodo(inicio, fim);
    }
}
