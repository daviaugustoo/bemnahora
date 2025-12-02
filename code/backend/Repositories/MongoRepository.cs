using MongoDB.Bson;
using MongoDB.Driver;
using System.Linq.Expressions;
using BemNaHoraAPI.Interfaces;

namespace BemNaHoraAPI.Repositories;

public class MongoRepository<T> : IRepository<T>
{
    protected readonly IMongoCollection<T> Collection;

    public MongoRepository(IMongoDatabase database, string collectionName)
    {
        Collection = database.GetCollection<T>(collectionName);
    }

    public virtual T? GetById(string id)
    {
        var objectId = new ObjectId(id); // MUITO NECESSARIO! tava dando bug em todo getbyid
        return Collection.Find(Builders<T>.Filter.Eq("_id", objectId)).FirstOrDefault();
    }

    public virtual bool Replace(string id, T entity)
    {
        var objectId = new ObjectId(id);
        var result = Collection.ReplaceOne(Builders<T>.Filter.Eq("_id", objectId), entity);
        return result.MatchedCount > 0;
    }

    public virtual bool Delete(string id)
    {
        var objectId = new ObjectId(id);
        var result = Collection.DeleteOne(Builders<T>.Filter.Eq("_id", objectId));
        return result.DeletedCount > 0;
    }

    public virtual List<T> GetAll() =>
        Collection.Find(_ => true).ToList();

    public virtual void Insert(T entity) =>
        Collection.InsertOne(entity);

    public virtual T? FirstOrDefault(Expression<Func<T, bool>> predicate) =>
        Collection.AsQueryable().FirstOrDefault(predicate);

    public virtual List<T> Find(Expression<Func<T, bool>> predicate) =>
        Collection.AsQueryable().Where(predicate).ToList();
}
