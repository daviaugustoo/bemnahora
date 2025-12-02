using BemNaHoraAPI.Interfaces;
using BemNaHoraAPI.Models;
using MongoDB.Driver;

namespace BemNaHoraAPI.Repositories
{
    public class CarrinhoRepository : MongoRepository<Carrinho>, ICarrinhoRepository
    {
        public CarrinhoRepository(IMongoDatabase database)
            : base(database, "carrinhos") { }
    }
}
