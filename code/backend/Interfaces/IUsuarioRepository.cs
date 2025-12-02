using BemNaHoraAPI.Models;

namespace BemNaHoraAPI.Interfaces;

public interface IUsuarioRepository : IRepository<Usuario>
{
    Usuario? GetByUsername(string username);

    List<Entregador> GetEntregadores();
    List<Consumidor> GetConsumidores();
    List<Distribuidora> GetDistribuidoras();

    Usuario? Update(string id, Usuario usuario); 
    Usuario? Delete(string id); 
    
}
