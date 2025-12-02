using BemNaHoraAPI.Interfaces;
using BemNaHoraAPI.Models;

namespace BemNaHoraAPI.Services
{
    public class ProdutoService
    {
        private readonly IProdutoRepository _repo;

        public ProdutoService(IProdutoRepository repo)
        {
            _repo = repo;
        }

        public Produto? GetById(string id) => _repo.GetById(id);

        public List<Produto> GetAll() => _repo.GetAll();

        public Produto? GetByNome(string nome) => _repo.GetByNome(nome);

        public List<Produto> SearchByNome(string termo) => _repo.SearchByNome(termo);

        public void Create(Produto produto)
        {
            try
            {
                _repo.Insert(produto);
            }
            catch (Exception ex)
            {
                // Trata duplicidade por índice único de Nome
                if (ex.Message.Contains("E11000") || ex.Message.Contains("duplicate"))
                    throw new Exception("Já existe um produto com este nome.");
                throw;
            }
        }

        public bool Update(string id, Produto produto)
        {
            produto.Id = id;
            return _repo.Replace(id, produto);
        }

        public bool Delete(string id) => _repo.Delete(id);
    }
}
