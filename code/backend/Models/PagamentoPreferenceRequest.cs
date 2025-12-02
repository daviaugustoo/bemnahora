namespace backend.Models
{
    public class PagamentoPreferenceRequest
    {
        public string Titulo { get; set; } = string.Empty;
        public decimal Preco { get; set; }
        public int Quantidade { get; set; }
        public string? BackUrl { get; set; }
    }
}
