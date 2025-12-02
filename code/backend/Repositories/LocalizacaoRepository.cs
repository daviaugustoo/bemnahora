using MongoDB.Driver;
using BemNaHoraAPI.Interfaces;
using BemNaHoraAPI.Models;

namespace BemNaHoraAPI.Repositories
{
    public class LocalizacaoRepository : ILocalizacaoRepository
    {
        private readonly IMongoCollection<Localizacao> _localizacoes;

        public LocalizacaoRepository(IMongoDatabase database)
        {
            _localizacoes = database.GetCollection<Localizacao>("Localizacoes");
        }

        public List<Localizacao> GetAll() => _localizacoes.Find(_ => true).ToList();

        public Localizacao? GetById(string id) => _localizacoes.Find(l => l.Id == id).FirstOrDefault();

        public List<Localizacao> GetByUsuarioId(string usuarioId) => 
            _localizacoes.Find(l => l.UsuarioId == usuarioId).ToList();

        public void Create(Localizacao localizacao) => _localizacoes.InsertOne(localizacao);

        public void Update(string id, Localizacao localizacao) => 
            _localizacoes.ReplaceOne(l => l.Id == id, localizacao);

        public void Delete(string id) => _localizacoes.DeleteOne(l => l.Id == id);
    }
}
