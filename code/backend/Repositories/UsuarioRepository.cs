using BemNaHoraAPI.Interfaces;
using BemNaHoraAPI.Models;
using MongoDB.Driver;
using MongoDB.Driver.Linq;

namespace BemNaHoraAPI.Repositories;

public class UsuarioRepository : MongoRepository<Usuario>, IUsuarioRepository
{
    public UsuarioRepository(IMongoDatabase database) : base(database, "Usuarios")
    {
        var indexOptions = new CreateIndexOptions { Unique = true };
        var indexKeys = Builders<Usuario>.IndexKeys.Ascending(u => u.Username);
        var indexModel = new CreateIndexModel<Usuario>(indexKeys, indexOptions);
        Collection.Indexes.CreateOne(indexModel);
    }

    public Usuario? GetByUsername(string username) =>
        Collection.Find(u => u.Username == username).FirstOrDefault();

    public List<Entregador> GetEntregadores() =>
        Collection.AsQueryable().OfType<Entregador>().ToList();

    public List<Consumidor> GetConsumidores() =>
        Collection.AsQueryable().OfType<Consumidor>().ToList();

    public List<Distribuidora> GetDistribuidoras() =>
        Collection.AsQueryable().OfType<Distribuidora>().ToList();

    public Usuario? Update(string id, Usuario usuario)
    {
        var result = Collection.ReplaceOne(u => u.Id == id, usuario);
        return (result.IsAcknowledged && result.ModifiedCount > 0) ? usuario : null;
    }

    public new Usuario? Delete(string id)
    {
        var usuario = Collection.Find(u => u.Id == id).FirstOrDefault();
        if (usuario == null) return null;

        var result = Collection.DeleteOne(u => u.Id == id);
        return (result.IsAcknowledged && result.DeletedCount > 0) ? usuario : null;
    }
}
