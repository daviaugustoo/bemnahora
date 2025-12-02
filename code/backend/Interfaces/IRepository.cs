using System.Linq.Expressions;

namespace BemNaHoraAPI.Interfaces;

public interface IRepository<T>
{
    T? GetById(string id);
    List<T> GetAll();
    void Insert(T entity);
    bool Replace(string id, T entity);
    bool Delete(string id);

    // Extras úteis
    T? FirstOrDefault(Expression<Func<T, bool>> predicate);
    List<T> Find(Expression<Func<T, bool>> predicate);
}
