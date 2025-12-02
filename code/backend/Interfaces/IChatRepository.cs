using BemNaHoraAPI.Models;

namespace BemNaHoraAPI.Interfaces;

public interface IChatRepository
{
    void Insert(ChatMessage m);
    List<ChatMessage> GetHistorico(string pedidoId, int limit = 50);
}
