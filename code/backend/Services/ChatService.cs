using BemNaHoraAPI.Interfaces;
using BemNaHoraAPI.Models;

namespace BemNaHoraAPI.Services;

public class ChatService
{
    private readonly IChatRepository _repo;
    public ChatService(IChatRepository repo) => _repo = repo;

    public void SalvarMensagem(ChatMessage msg) => _repo.Insert(msg);

    public List<ChatMessage> Historico(string pedidoId, int limit = 50) =>
        _repo.GetHistorico(pedidoId, limit);
}
