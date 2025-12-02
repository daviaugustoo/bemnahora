using Microsoft.AspNetCore.Mvc;
using BemNaHoraAPI.Services;
using BemNaHoraAPI.Models;

namespace BemNaHoraAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PagamentoController : ControllerBase
    {
        private readonly PagamentoService _pagamentoService;
        private readonly PedidoService _pedidoService;

        public PagamentoController(PagamentoService pagamentoService, PedidoService pedidoService)
        {
            _pagamentoService = pagamentoService;
            _pedidoService = pedidoService;
        }

        // === Método principal de pagamento, chamado pelo PedidoController ===
        [HttpPost("pagar/{pedidoId}")]
        public async Task<IActionResult> RealizarPagamento(string pedidoId, [FromQuery] string? backUrl = null)
        {
            try
            {
                // Se o backUrl não for informado pelo cliente, constrói a base a partir do request atual
                if (string.IsNullOrWhiteSpace(backUrl))
                {
                    var requestBase = $"{Request.Scheme}://{Request.Host.Value}";
                    backUrl = requestBase;
                }

                var result = await _pagamentoService.CriarPreferenciaPorPedidoAsync(pedidoId, backUrl);
                _pedidoService.AlterarStatus(pedidoId, StatusPedido.Pendente);

                return Ok(new
                {
                    pedidoId,
                    preferenceId = result.PreferenceId,
                    initPoint = result.InitPoint
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        // === Webhook do Mercado Pago ===
        [HttpPost("notificacao")]
        public IActionResult ReceberNotificacao([FromBody] dynamic payload)
        {
            Console.WriteLine("Notificação recebida do Mercado Pago:");
            Console.WriteLine(payload?.ToString());

            // TODO: consultar o pagamento via API e atualizar o pedido no banco
            return Ok();
        }
    }
}
