# Bem na Hora - Flutter App

Esta é a versão Flutter do aplicativo "Bem na Hora", uma plataforma digital para distribuidoras.

## Funcionalidades Implementadas

### ✅ Autenticação
- Login e registro de usuários
- Diferentes tipos de usuário (Admin, Cliente, Entregador)
- Gerenciamento de sessão com armazenamento seguro
- Logout automático

### ✅ Páginas Principais
- **Home Page**: Landing page com informações da empresa
- **Login Page**: Formulário de autenticação
- **Register Page**: Formulário de cadastro com validação
- **Dashboard**: Painel principal com ações rápidas baseadas no tipo de usuário
- **Catálogo**: Listagem de produtos com busca e filtros

### ✅ Componentes UI
- **ProductCard**: Card de produto com imagem, preço e controles de quantidade
- **AppDrawer**: Menu lateral responsivo com navegação baseada no usuário
- Design responsivo e moderno

### ✅ Gerenciamento de Estado
- **AuthProvider**: Gerencia estado de autenticação
- **ProductProvider**: Gerencia produtos, busca e filtros
- **CartProvider**: Gerencia carrinho de compras (persistente)

### ✅ Integração com Backend
- Serviço de API configurado para se conectar com o backend Next.js
- Autenticação via JWT
- Interceptors para adicionar tokens automaticamente

## Estrutura do Projeto

```
lib/
├── config/
│   └── routes.dart              # Configuração de rotas com GoRouter
├── models/
│   ├── user.dart               # Modelo de usuário
│   ├── product.dart            # Modelo de produto
│   ├── cart.dart               # Modelos de carrinho e pedidos
│   └── models.dart             # Exports dos modelos
├── providers/
│   ├── auth_provider.dart      # Provider de autenticação
│   ├── product_provider.dart   # Provider de produtos
│   └── cart_provider.dart      # Provider do carrinho
├── services/
│   ├── api_service.dart        # Cliente HTTP base
│   ├── auth_service.dart       # Serviços de autenticação
│   └── product_service.dart    # Serviços de produtos
├── pages/
│   ├── home_page.dart          # Página inicial
│   ├── login_page.dart         # Página de login
│   ├── register_page.dart      # Página de cadastro
│   ├── dashboard_page.dart     # Dashboard principal
│   └── catalog_page.dart       # Catálogo de produtos
├── widgets/
│   ├── app_drawer.dart         # Menu lateral
│   └── product_card.dart       # Card de produto
└── main.dart                   # Entry point da aplicação
```

## Dependências Principais

- **flutter**: Framework base
- **provider**: Gerenciamento de estado
- **go_router**: Navegação e roteamento
- **dio**: Cliente HTTP
- **flutter_secure_storage**: Armazenamento seguro
- **shared_preferences**: Armazenamento local
- **cached_network_image**: Cache de imagens
- **fluttertoast**: Notificações toast

## Como Executar

### Pré-requisitos
- Flutter SDK (versão 3.9.2 ou superior)
- Dart SDK
- Android Studio ou VS Code com extensões Flutter
- Emulador Android/iOS ou dispositivo físico

### Passos para Execução

1. **Navegue para o diretório do projeto Flutter:**
   ```bash
   cd bem_na_hora_flutter
   ```

2. **Instale as dependências:**
   ```bash
   flutter pub get
   ```

3. **Configure o backend:**
   - Certifique-se de que o servidor Next.js esteja rodando em `http://localhost:3000`
   - Se necessário, altere a URL base em `lib/services/api_service.dart`

4. **Execute o aplicativo:**
   ```bash
   flutter run
   ```

   Ou para web:
   ```bash
   flutter run -d web-server --web-port 8080
   ```

## Configuração de Backend

O app está configurado para se conectar com o backend Next.js em `http://localhost:3000/api`.

Se o backend estiver em um endereço diferente, altere a constante `_baseUrl` no arquivo `lib/services/api_service.dart`:

```dart
static const String _baseUrl = 'http://SEU_ENDERECO:PORTA/api';
```

## Funcionalidades por Tipo de Usuário

### Cliente
- ✅ Visualizar catálogo de produtos
- ✅ Buscar e filtrar produtos
- ✅ Adicionar produtos ao carrinho
- 🔄 Finalizar pedidos (em desenvolvimento)
- 🔄 Acompanhar entregas (em desenvolvimento)
- 🔄 Chat com suporte (em desenvolvimento)

### Administrador  
- ✅ Dashboard com estatísticas
- 🔄 Gerenciar produtos (em desenvolvimento)
- 🔄 Gerenciar pedidos (em desenvolvimento)
- 🔄 Gerenciar usuários (em desenvolvimento)
- 🔄 Monitorar entregas (em desenvolvimento)

### Entregador
- 🔄 Visualizar entregas atribuídas (em desenvolvimento)
- 🔄 Atualizar status de entrega (em desenvolvimento)
- 🔄 Otimizar rotas (em desenvolvimento)

## Próximos Passos

1. **Carrinho e Checkout**: Implementar fluxo completo de compra
2. **Páginas Admin**: Desenvolver CRUD de produtos, usuários e pedidos
3. **Rastreamento**: Implementar rastreamento em tempo real
4. **Chat**: Sistema de mensagens entre cliente e suporte
5. **Notificações Push**: Alertas de pedidos e entregas
6. **Modo Offline**: Cache e sincronização offline
7. **Testes**: Implementar testes unitários e de integração

## Tecnologias Utilizadas

- **Flutter/Dart**: Framework de desenvolvimento
- **Provider**: Gerenciamento de estado
- **GoRouter**: Roteamento declarativo
- **Dio**: Cliente HTTP robusto
- **Material Design 3**: Design system moderno
- **JWT**: Autenticação baseada em tokens

## Comparação com o Frontend Next.js

| Funcionalidade | Next.js | Flutter | Status |
|---|---|---|---|
| Autenticação | ✅ NextAuth | ✅ JWT + Providers | Migrado |
| Página Home | ✅ | ✅ | Migrado |
| Login/Registro | ✅ | ✅ | Migrado |
| Dashboard | ✅ | ✅ | Migrado |
| Catálogo | ✅ | ✅ | Migrado |
| Carrinho | ✅ | 🔄 | Em desenvolvimento |
| Admin Panel | ✅ | 🔄 | Em desenvolvimento |
| Responsividade | ✅ | ✅ | Implementado |
| Navegação | ✅ | ✅ | Implementado |

## Melhorias em Relação ao Next.js

- **Performance Nativa**: Melhor performance em dispositivos móveis
- **Offline First**: Suporte nativo a funcionalidades offline
- **Animações**: Animações mais fluidas e responsivas
- **Estado Persistente**: Carrinho e preferências mantidos entre sessões
- **Cross-Platform**: Um código para Web, Android e iOS
- **Hot Reload**: Desenvolvimento mais rápido com recarga instantânea
