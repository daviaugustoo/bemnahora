using System.Text.Json;
using BemNaHoraAPI.Interfaces;
using BemNaHoraAPI.Models;

namespace BemNaHoraAPI.Services
{
    public class OpenStreetMapService
    {
        private readonly ILocalizacaoRepository _localizacaoRepo;
        private readonly HttpClient _httpClient;
        private readonly string _userAgent;

        public OpenStreetMapService(ILocalizacaoRepository localizacaoRepo, IConfiguration configuration)
        {
            _localizacaoRepo = localizacaoRepo;
            _httpClient = new HttpClient();
            _userAgent = configuration["OpenStreetMap:UserAgent"] ?? "BemNaHoraAPI/1.0";
            _httpClient.DefaultRequestHeaders.Add("User-Agent", _userAgent);
        }

        // === Geocodificar endereço para coordenadas (Nominatim) ===
        public async Task<EnderecoGeocodificado?> GeocodificarEnderecoAsync(string endereco)
        {
            await Task.Delay(1000); // Nominatim exige 1 req/segundo

            var url = $"https://nominatim.openstreetmap.org/search?q={Uri.EscapeDataString(endereco)}&format=json&addressdetails=1&limit=1";

            var response = await _httpClient.GetAsync(url);

            if (!response.IsSuccessStatusCode)
                throw new Exception("Erro ao geocodificar endereço.");

            var content = await response.Content.ReadAsStringAsync();
            var results = JsonSerializer.Deserialize<List<JsonElement>>(content);

            if (results == null || results.Count == 0) return null;

            var result = results[0];
            var address = result.GetProperty("address");

            return new EnderecoGeocodificado
            {
                EnderecoFormatado = result.GetProperty("display_name").GetString() ?? "",
                Latitude = double.Parse(result.GetProperty("lat").GetString() ?? "0"),
                Longitude = double.Parse(result.GetProperty("lon").GetString() ?? "0"),
                Pais = address.TryGetProperty("country", out var pais) ? pais.GetString() ?? "" : "",
                Estado = address.TryGetProperty("state", out var estado) ? estado.GetString() ?? "" : "",
                Cidade = address.TryGetProperty("city", out var cidade) ? 
                         cidade.GetString() ?? 
                         (address.TryGetProperty("town", out var town) ? town.GetString() ?? "" : "") : "",
                CEP = address.TryGetProperty("postcode", out var cep) ? cep.GetString() ?? "" : "",
                Bairro = address.TryGetProperty("suburb", out var bairro) ? bairro.GetString() ?? "" : "",
                Rua = address.TryGetProperty("road", out var rua) ? rua.GetString() ?? "" : ""
            };
        }

        // === Geocodificar reverso (coordenadas para endereço) ===
        public async Task<string> GeocodificarReversoAsync(double latitude, double longitude)
        {
            await Task.Delay(1000); // Nominatim exige 1 req/segundo

            var url = $"https://nominatim.openstreetmap.org/reverse?lat={latitude}&lon={longitude}&format=json&addressdetails=1";

            var response = await _httpClient.GetAsync(url);

            if (!response.IsSuccessStatusCode)
                throw new Exception("Erro ao fazer geocodificação reversa.");

            var content = await response.Content.ReadAsStringAsync();
            var json = JsonSerializer.Deserialize<JsonElement>(content);

            return json.GetProperty("display_name").GetString() ?? "Endereço não encontrado";
        }

        // === Calcular rota entre dois pontos (OSRM) ===
        public async Task<RotaResponse?> CalcularRotaAsync(double latOrigem, double lonOrigem, double latDestino, double lonDestino)
        {
            var url = $"http://router.project-osrm.org/route/v1/driving/{lonOrigem},{latOrigem};{lonDestino},{latDestino}?overview=full&geometries=geojson";

            var response = await _httpClient.GetAsync(url);

            if (!response.IsSuccessStatusCode)
                throw new Exception("Erro ao calcular rota.");

            var content = await response.Content.ReadAsStringAsync();
            var json = JsonSerializer.Deserialize<JsonElement>(content);

            var routes = json.GetProperty("routes");
            if (routes.GetArrayLength() == 0) return null;

            var route = routes[0];
            var distanciaMetros = route.GetProperty("distance").GetDouble();
            var duracaoSegundos = route.GetProperty("duration").GetDouble();

            var geometry = route.GetProperty("geometry");
            var coordinates = geometry.GetProperty("coordinates");

            var coordenadas = new List<Coordenada>();
            foreach (var coord in coordinates.EnumerateArray())
            {
                var lon = coord[0].GetDouble();
                var lat = coord[1].GetDouble();
                coordenadas.Add(new Coordenada
                {
                    Latitude = lat,
                    Longitude = lon
                });
            }

            return new RotaResponse
            {
                DistanciaKm = distanciaMetros / 1000,
                DuracaoMinutos = (int)(duracaoSegundos / 60),
                Coordenadas = coordenadas
            };
        }

        // === Calcular distância direta entre dois pontos (Haversine) ===
        public double CalcularDistanciaDireta(double lat1, double lon1, double lat2, double lon2)
        {
            const double R = 6371; // Raio da Terra em km

            var dLat = (lat2 - lat1) * Math.PI / 180;
            var dLon = (lon2 - lon1) * Math.PI / 180;

            var a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                    Math.Cos(lat1 * Math.PI / 180) * Math.Cos(lat2 * Math.PI / 180) *
                    Math.Sin(dLon / 2) * Math.Sin(dLon / 2);

            var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));

            return R * c;
        }

        // === Salvar localização no banco ===
        public void SalvarLocalizacao(string usuarioId, string endereco, double latitude, double longitude)
        {
            var localizacao = new Localizacao
            {
                UsuarioId = usuarioId,
                Endereco = endereco,
                Latitude = latitude,
                Longitude = longitude
            };

            _localizacaoRepo.Create(localizacao);
        }

        // === Buscar localizações do usuário ===
        public List<Localizacao> ObterLocalizacoesUsuario(string usuarioId)
        {
            return _localizacaoRepo.GetByUsuarioId(usuarioId);
        }

        // === Buscar localizações próximas ===
        public List<Localizacao> BuscarLocalizacoesProximas(double latitude, double longitude, double raioKm)
        {
            var todasLocalizacoes = _localizacaoRepo.GetAll();

            return todasLocalizacoes
                .Where(l => CalcularDistanciaDireta(latitude, longitude, l.Latitude, l.Longitude) <= raioKm)
                .ToList();
        }
    }
}
