using BemNaHoraAPI.Interfaces;
using BemNaHoraAPI.Models;

namespace BemNaHoraAPI.Services
{
    public class CarrinhoService
    {
        private readonly ICarrinhoRepository _repo;
        private readonly IPedidoRepository _pedidoRepo;

        public CarrinhoService(ICarrinhoRepository repo, IPedidoRepository pedidoRepo)
        {
            _repo = repo;
            _pedidoRepo = pedidoRepo;
        }

        // CRUD do carrinho
        public List<Carrinho> GetAll() => _repo.GetAll();

        public Carrinho? GetById(string id) => _repo.GetById(id);

        public void Create(Carrinho carrinho)
        {
            carrinho.Itens ??= new List<ItemCarrinho>();
            _repo.Insert(carrinho);
        }

        public bool Update(string id, Carrinho carrinho)
        {
            carrinho.Id = id;
            return _repo.Replace(id, carrinho);
        }

        public bool Delete(string id) => _repo.Delete(id);

        // ===== Manipulação de itens =====
        public void AdicionarItem(string carrinhoId, Produto produto, int quantidade)
        {
            var carrinho = _repo.GetById(carrinhoId) ?? throw new Exception("Carrinho não encontrado.");

            // procurar por item existente usando produtoId (se disponível) ou pelo objeto Produto
            var itemExistente = carrinho.Itens.FirstOrDefault(i =>
                (!string.IsNullOrEmpty(i.ProdutoId) && i.ProdutoId == produto.Id) ||
                (i.Produto != null && i.Produto.Id == produto.Id)
            );

            if (itemExistente != null)
            {
                itemExistente.Quantidade += quantidade;
                // atualiza preço unitário caso necessário
                itemExistente.PrecoUnitario = produto.Preco;
                itemExistente.Produto = produto;
                itemExistente.ProdutoId = produto.Id;
            }
            else
            {
                carrinho.Itens.Add(new ItemCarrinho
                {
                    Produto = produto,
                    ProdutoId = produto.Id,
                    Quantidade = quantidade,
                    PrecoUnitario = produto.Preco
                });
            }

            _repo.Replace(carrinhoId, carrinho);
        }

        public void RemoverItem(string carrinhoId, string produtoId)
        {
            var carrinho = _repo.GetById(carrinhoId) ?? throw new Exception("Carrinho não encontrado.");
            carrinho.Itens.RemoveAll(i => (i.Produto != null && i.Produto.Id == produtoId) || (i.ProdutoId == produtoId));
            _repo.Replace(carrinhoId, carrinho);
        }

        public double CalcularTotal(string carrinhoId)
        {
            var carrinho = _repo.GetById(carrinhoId) ?? throw new Exception("Carrinho não encontrado.");
            return carrinho.Total;
        }

        public Pedido FinalizarCompra(string carrinhoId)
        {
            var carrinho = _repo.GetById(carrinhoId) ?? throw new Exception("Carrinho não encontrado.");

            var pedido = new Pedido
            {
                Carrinho = carrinho,
                ValorTotal = carrinho.Total
            };

            _pedidoRepo.Insert(pedido);

            carrinho.Itens.Clear();
            _repo.Replace(carrinhoId, carrinho);

            return pedido;
        }
    }
}
