using BemNaHoraAPI.Models;

namespace BemNaHoraAPI.Interfaces
{
    public interface ILocalizacaoRepository
    {
        List<Localizacao> GetAll();
        Localizacao? GetById(string id);
        List<Localizacao> GetByUsuarioId(string usuarioId);
        void Create(Localizacao localizacao);
        void Update(string id, Localizacao localizacao);
        void Delete(string id);
    }
}
