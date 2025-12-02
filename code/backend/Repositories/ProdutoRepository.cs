using BemNaHoraAPI.Interfaces;
using BemNaHoraAPI.Models;
using MongoDB.Driver;
using MongoDB.Driver.Linq;

namespace BemNaHoraAPI.Repositories
{
    public class ProdutoRepository : MongoRepository<Produto>, IProdutoRepository
    {
        public ProdutoRepository(IMongoDatabase database) : base(database, "Produtos")
        {
            var indexOptions = new CreateIndexOptions { Unique = true };
            var indexKeys = Builders<Produto>.IndexKeys.Ascending(p => p.Nome);
            var indexModel = new CreateIndexModel<Produto>(indexKeys, indexOptions);
            Collection.Indexes.CreateOne(indexModel);
        }

        public Produto? GetByNome(string nome) =>
            Collection.Find(p => p.Nome == nome).FirstOrDefault();

        public List<Produto> SearchByNome(string termo)
        {
            return Collection.AsQueryable()
                             .Where(p => p.Nome.ToLower().Contains(termo.ToLower()))
                             .ToList();
        }
    }
}
