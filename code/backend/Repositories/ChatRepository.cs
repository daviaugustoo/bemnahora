using BemNaHoraAPI.Interfaces;
using BemNaHoraAPI.Models;
using MongoDB.Driver;

namespace BemNaHoraAPI.Repositories;

public class ChatRepository : IChatRepository
{
    private readonly IMongoCollection<ChatMessage> _col;
    public ChatRepository(IMongoDatabase db)
    {
        _col = db.GetCollection<ChatMessage>("chat_messages");
        // índices úteis
        var idx = Builders<ChatMessage>.IndexKeys
            .Ascending(m => m.PedidoId)
            .Ascending(m => m.EnviadoEmUtc);
        _col.Indexes.CreateOne(new CreateIndexModel<ChatMessage>(idx));
    }

    public void Insert(ChatMessage m) => _col.InsertOne(m);

    public List<ChatMessage> GetHistorico(string pedidoId, int limit = 50) =>
        _col.Find(m => m.PedidoId == pedidoId)
            .SortByDescending(m => m.EnviadoEmUtc)
            .Limit(limit)
            .ToList()
            .OrderBy(m => m.EnviadoEmUtc)
            .ToList();
}
