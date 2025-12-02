using BemNaHoraAPI.Interfaces;
using BemNaHoraAPI.Models;

namespace BemNaHoraAPI.Services;

public class UsuarioService
{
    private readonly IUsuarioRepository _repo;

    public UsuarioService(IUsuarioRepository repo)
    {
        _repo = repo;
    }

    public void CreateEntregador(Entregador entregador)
    {
        try
        {
            _repo.Insert(entregador);
        }
        catch (Exception ex)
        {
            if (ex.Message.Contains("E11000") || ex.Message.Contains("duplicate"))
                throw new Exception("Username já existe!");
            throw;
        }
    }

    public void CreateDistribuidora(Distribuidora distribuidora)
    {
        try
        {
            _repo.Insert(distribuidora);
        }
        catch (Exception ex)
        {
            if (ex.Message.Contains("E11000") || ex.Message.Contains("duplicate"))
                throw new Exception("Username já existe!");
            throw;
        }
    }

    public void CreateConsumidor(Consumidor consumidor)
    {
        try
        {
            _repo.Insert(consumidor);
        }
        catch (Exception ex)
        {
            if (ex.Message.Contains("E11000") || ex.Message.Contains("duplicate"))
                throw new Exception("Username já existe!");
            throw;
        }
    }

    public Usuario? GetByUsername(string username) =>
        _repo.GetByUsername(username);

    public Usuario? GetById(string id) =>
        _repo.GetById(id);

    public bool Delete(string id)
    {
        var usuario = _repo.GetById(id);
        if (usuario == null)
            return false;

        _repo.Delete(id);
        return true;
    }

    public List<Usuario> GetAll() => _repo.GetAll();
    public List<Entregador> GetEntregadores() => _repo.GetEntregadores();
    public List<Consumidor> GetConsumidores() => _repo.GetConsumidores();
    public List<Distribuidora> GetDistribuidoras() => _repo.GetDistribuidoras();
}