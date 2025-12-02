using MercadoPago.Client.Preference;
using MercadoPago.Resource.Preference;
using BemNaHoraAPI.Interfaces;
using backend.Models;
using System.Text.Json;

namespace BemNaHoraAPI.Services
{
    public class PagamentoService
    {
        private readonly IPedidoRepository _pedidoRepo;

        public PagamentoService(IPedidoRepository pedidoRepo)
        {
            _pedidoRepo = pedidoRepo;
        }

        public async Task<PagamentoPreferenceResponse> CriarPreferenciaPorPedidoAsync(string pedidoId, string? backUrl = null)
        {
            var pedido = _pedidoRepo.GetById(pedidoId) ?? throw new Exception("Pedido não encontrado.");

            if (pedido.Carrinho?.Itens == null || !pedido.Carrinho.Itens.Any())
                throw new Exception("Pedido sem itens.");

            var items = pedido.Carrinho.Itens.Select(i => new PreferenceItemRequest
            {
                Title = i.Produto?.Nome ?? "Produto desconhecido",
                Quantity = i.Quantidade,
                UnitPrice = (decimal)(i.Produto?.Preco ?? 0)
            }).ToList();

            // Valida backUrl para evitar "null/success" ou urls inválidas enviadas ao Mercado Pago
            // Se não informado ou se for uma URL local/insegura, usamos um fallback público para evitar 400 do MP
            var baseBackUrl = backUrl?.TrimEnd('/');
            if (string.IsNullOrWhiteSpace(baseBackUrl))
            {
                Console.WriteLine("[PagamentoService] backUrl não informada — usando fallback público para desenvolvimento.");
                baseBackUrl = "https://www.mercadopago.com.br";
            }

            // Se a URL não possuir esquema ou não for HTTPS, emitir log e usar fallback. O Mercado Pago costuma exigir URLs públicas/HTTPS.
            try
            {
                var uri = new Uri(baseBackUrl);

                // Se não for HTTPS ou se for uma URL local/loopback (localhost, 127.0.0.1, ::1), usamos fallback.
                // O Mercado Pago exige URLs públicas acessíveis; enviar localhost causa 400.
                if (!uri.Scheme.Equals("https", StringComparison.OrdinalIgnoreCase) || uri.IsLoopback)
                {
                    Console.WriteLine($"[PagamentoService] backUrl inválida/Local ou sem HTTPS ({baseBackUrl}) — usando fallback público.");
                    baseBackUrl = "https://www.mercadopago.com.br";
                }
            }
            catch
            {
                Console.WriteLine($"[PagamentoService] backUrl inválida ({baseBackUrl}) — usando fallback público.");
                baseBackUrl = "https://www.mercadopago.com.br";
            }

            var preferenceRequest = new PreferenceRequest
            {
                Items = items,
                BackUrls = new PreferenceBackUrlsRequest
                {
                    Success = backUrl + "/success",
                    Failure = backUrl + "/failure",
                    Pending = backUrl + "/pending"
                },
                AutoReturn = "approved"
            };

            var client = new PreferenceClient();
            try
            {
                // Loga a preferência que será enviada para facilitar diagnóstico de 400
                try
                {
                    var dump = JsonSerializer.Serialize(preferenceRequest, new JsonSerializerOptions { WriteIndented = true });
                    Console.WriteLine("[PagamentoService] PreferenceRequest:\n" + dump);
                }
                catch
                {
                    Console.WriteLine("[PagamentoService] Não foi possível serializar PreferenceRequest para log.");
                }

                var preference = await client.CreateAsync(preferenceRequest);

                return new PagamentoPreferenceResponse
                {
                    PreferenceId = preference.Id,
                    InitPoint = preference.InitPoint
                };
            }
            catch (Exception ex)
            {
                // Log da exceção completa para obter detalhes retornados pelo Mercado Pago (body/status)
                Console.WriteLine("[PagamentoService] Erro ao criar preferência no Mercado Pago: " + ex.ToString());

                // Re-lançar com detalhes completos (útil durante desenvolvimento)
                throw new Exception("Falha ao criar preferência no Mercado Pago: " + ex.ToString());
            }
        }
    }
}
