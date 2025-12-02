using BemNaHoraAPI.Models;
using BemNaHoraAPI.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace BemNaHoraAPI.Hubs;

// [Authorize] // se usar JWT, ative e recupere claims para saber quem é
public class ChatHub : Hub
{
    private readonly ChatService _chat;

    public ChatHub(ChatService chat) => _chat = chat;

    // Cliente chama após conectar para entrar na sala do pedido
    public async Task JoinPedido(string pedidoId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, GroupName(pedidoId));
    }

    // Enviar mensagem
    public async Task SendMessage(string pedidoId, string remetenteId, string remetenteTipo, string texto)
    {
        var msg = new ChatMessage
        {
            PedidoId = pedidoId,
            RemetenteId = remetenteId,
            RemetenteTipo = remetenteTipo,
            Texto = texto,
            EnviadoEmUtc = DateTime.UtcNow
        };

        _chat.SalvarMensagem(msg);

        // Broadcast para todos da sala do pedido
        await Clients.Group(GroupName(pedidoId)).SendAsync("ReceiveMessage", new
        {
            id = msg.Id,
            pedidoId = msg.PedidoId,
            remetenteId = msg.RemetenteId,
            remetenteTipo = msg.RemetenteTipo,
            texto = msg.Texto,
            enviadoEmUtc = msg.EnviadoEmUtc
        });
    }

    // Opcional: retornar histórico (últimas N)
    public List<ChatMessage> GetHistorico(string pedidoId, int limit = 50) =>
        _chat.Historico(pedidoId, limit);

    private static string GroupName(string pedidoId) => $"pedido:{pedidoId}";
}
