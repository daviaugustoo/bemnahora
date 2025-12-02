using BemNaHoraAPI.Models;
using BemNaHoraAPI.Services;
using Microsoft.AspNetCore.Mvc;
using System.Drawing;
using System.Drawing.Imaging;
using Microsoft.AspNetCore.Http;

namespace BemNaHoraAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProdutoController : ControllerBase
    {
        private readonly ProdutoService _service;

        public ProdutoController(ProdutoService service)
        {
            _service = service;
        }

        [HttpPost]
        public IActionResult Create([FromBody] Produto produto)
        {
            _service.Create(produto);
            return CreatedAtAction(nameof(GetById), new { id = produto.Id }, produto);
        }

        [HttpGet("{id}")]
        public IActionResult GetById(string id)
        {
            var prod = _service.GetById(id);
            if (prod == null) return NotFound();
            return Ok(prod);
        }

        [HttpGet]
        public IActionResult GetAll()
        {
            var produtos = _service.GetAll(); 

            return Ok(produtos);
            
            //  var categorias = produtos
            //     .Select(p => p.Categoria.ToString()) 
            //     .Distinct()                          
            //     .ToList();
            // return Ok(new {
            //     products = produtos,
            //     categories = categorias
            // });
        }

        [HttpGet("by-nome/{nome}")]
        public IActionResult GetByNome(string nome)
        {
            var prod = _service.GetByNome(nome);
            if (prod == null) return NotFound();
            return Ok(prod);
        }

        [HttpGet("search")]
        public IActionResult Search([FromQuery] string q)
        {
            var list = _service.SearchByNome(q ?? "");
            return Ok(list);
        }

        [HttpPut("{id}")]
        public IActionResult Update(string id, [FromBody] Produto produto)
        {
            var ok = _service.Update(id, produto);
            return ok ? NoContent() : NotFound();
        }

        [HttpDelete("{id}")]
        public IActionResult Delete(string id)
        {
            var ok = _service.Delete(id);
            return ok ? NoContent() : NotFound();
        }

        [HttpPost("{id}/imagem")]
        [RequestSizeLimit(5 * 1024 * 1024)] // limite de 5MB (ajuste se quiser)
        public async Task<IActionResult> UploadImagem(string id, IFormFile arquivo, CancellationToken cancellationToken)
        {
            // 1) Validar produto
            var produto = _service.GetById(id);
            if (produto == null)
                return NotFound("Produto não encontrado.");
        
            // 2) Validar arquivo
            if (arquivo == null || arquivo.Length == 0)
                return BadRequest("Nenhum arquivo enviado.");
        
            // Tipos permitidos
            var extensoesPermitidas = new[] { ".jpg", ".jpeg", ".png" };
            var ext = Path.GetExtension(arquivo.FileName).ToLowerInvariant();
        
            if (string.IsNullOrEmpty(ext) || !extensoesPermitidas.Contains(ext))
                return BadRequest("Formato de imagem inválido. Envie JPG ou PNG.");
        
            // Limite de tamanho (ex.: 5MB)
            const long tamanhoMaxBytes = 5 * 1024 * 1024;
            if (arquivo.Length > tamanhoMaxBytes)
                return BadRequest("Arquivo muito grande. Máximo permitido é 5MB.");
        
            // 3) Garantir pasta wwwroot/imagens
            var webRootPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            var pastaImagens = Path.Combine(webRootPath, "imagens");
        
            if (!Directory.Exists(pastaImagens))
                Directory.CreateDirectory(pastaImagens);
        
            // 4) Gerar nome único (sempre salvar como JPG)
            var nomeArquivo = $"{Guid.NewGuid():N}.jpg";
            var caminhoArquivo = Path.Combine(pastaImagens, nomeArquivo);
        
            // 5) COMPACTAR a imagem (converter para JPG com qualidade 75)
            using (var streamUpload = arquivo.OpenReadStream())
            using (var imagem = Image.FromStream(streamUpload))
            {
                // Opcional: redimensionar se for MUITO grande (ex.: largura máxima 1280)
                const int larguraMax = 1280;
                Image imagemFinal = imagem;
        
                if (imagem.Width > larguraMax)
                {
                    var novaAltura = (int)(imagem.Height * (larguraMax / (double)imagem.Width));
                    var bitmap = new Bitmap(larguraMax, novaAltura);
        
                    using (var g = Graphics.FromImage(bitmap))
                    {
                        g.CompositingQuality = System.Drawing.Drawing2D.CompositingQuality.HighQuality;
                        g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.HighQuality;
                        g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBicubic;
                        g.DrawImage(imagem, 0, 0, larguraMax, novaAltura);
                    }
        
                    imagemFinal = bitmap;
                }
        
                // Encoder JPEG com qualidade 75
                var jpegEncoder = ImageCodecInfo.GetImageDecoders()
                    .First(c => c.FormatID == ImageFormat.Jpeg.Guid);
        
                var encoderParams = new EncoderParameters(1);
                encoderParams.Param[0] = new EncoderParameter(Encoder.Quality, 75L);
        
                imagemFinal.Save(caminhoArquivo, jpegEncoder, encoderParams);
        
                if (!ReferenceEquals(imagemFinal, imagem))
                    imagemFinal.Dispose();
            }
        
            // 6) Salvar URL no produto (caminho relativo)
            produto.ImagemUrl = $"/imagens/{nomeArquivo}";
            _service.Update(id, produto);
        
            return Ok(new
            {
                message = "Imagem enviada com sucesso.",
                imagemUrl = produto.ImagemUrl
            });
        }
    }
}
