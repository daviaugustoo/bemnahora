using BemNaHoraAPI.Models;

namespace BemNaHoraAPI.Interfaces
{
    public interface IProdutoRepository : IRepository<Produto>
    {
        Produto? GetByNome(string nome);
        List<Produto> SearchByNome(string termo); // contém/startswith, etc.
    }
}
