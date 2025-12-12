# Lead Genius Admin

Aplicativo Flutter multi-tenant com duas áreas administrativas: **Cliente (Tenant Admin)** e **Super-Admin (Owner)**.

## 📋 Sumário

- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Tecnologias](#tecnologias)
- [Configuração](#configuração)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Executando o Projeto](#executando-o-projeto)
- [Banco de Dados](#banco-de-dados)
- [Autenticação & Autorização](#autenticação--autorização)
- [Rotas](#rotas)
- [Testes](#testes)
- [Build & Deploy](#build--deploy)

## 🎯 Visão Geral

### Área Cliente (Tenant Admin)
- Dashboard com métricas do tenant
- CRUD completo de Leads
- Gestão de Produtos/Serviços
- Gestão de Contratos (com export PDF)
- Relatórios por período
- Configurações do negócio
- Gestão de usuários do tenant

### Área Super-Admin (Owner)
- Dashboard global
- Gestão de Tenants
- Gestão de Usuários globais
- Auditoria (logs de ações)
- Ferramentas de suporte
- Painel de faturamento

## 🏗️ Arquitetura

O projeto segue **Clean Architecture + MVVM**:

```
lib/
├── app/              # Configuração do app (tema, rotas, constantes)
├── core/             # Providers, guards, errors
├── models/           # Modelos de dados
├── services/         # Lógica de negócio e comunicação com Supabase
├── repositories/     # Abstração de acesso a dados
├── controllers/      # Controladores MVVM
├── widgets/          # Componentes reutilizáveis
├── pages/            # Telas organizadas por área
└── utils/            # Utilitários (validação, formatação, export)
```

## 🛠️ Tecnologias

| Categoria | Tecnologia |
|-----------|------------|
| Framework | Flutter 3.x |
| Estado | Riverpod |
| Backend | Supabase (Auth + Database + Storage) |
| Navegação | go_router |
| Armazenamento | flutter_secure_storage |
| PDF/CSV | pdf, csv |
| Tema | Material 3 |

## ⚙️ Configuração

### 1. Pré-requisitos

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Conta no [Supabase](https://supabase.com)

### 2. Configurar Supabase

1. Crie um novo projeto no Supabase
2. Vá em **SQL Editor** e execute o script `supabase/migrations/001_initial_schema.sql`
3. Copie as chaves de API:
   - **Project URL**: Settings > API > Project URL
   - **anon key**: Settings > API > Project API keys > anon public
   - **service_role key**: Settings > API > Project API keys > service_role (apenas para scripts)

### 3. Configurar Variáveis de Ambiente

```bash
# Copie o arquivo de exemplo
cp .env.example .env

# Edite o arquivo .env com suas chaves
```

### 4. Instalar Dependências

```bash
flutter pub get
```

### 5. Gerar Código (se necessário)

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 📁 Estrutura do Projeto

```
lead_genius_admin/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   ├── routes.dart
│   │   ├── theme.dart
│   │   └── constants.dart
│   ├── core/
│   │   ├── providers/
│   │   ├── guards/
│   │   └── errors/
│   ├── models/
│   ├── services/
│   ├── repositories/
│   ├── controllers/
│   ├── widgets/
│   ├── pages/
│   │   ├── auth/
│   │   ├── client/
│   │   └── owner/
│   └── utils/
├── test/
├── supabase/
│   └── migrations/
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
├── .env.example
├── .env
├── pubspec.yaml
└── README.md
```

## 🚀 Executando o Projeto

### Desenvolvimento

```bash
# Executar em modo debug
flutter run

# Executar em dispositivo específico
flutter run -d chrome     # Web
flutter run -d windows    # Windows
flutter run -d <device>   # Mobile
```

### Hot Reload

Pressione `r` no terminal ou salve um arquivo para hot reload.

## 🗄️ Banco de Dados

### Tabelas Principais

| Tabela | Descrição |
|--------|-----------|
| `users` | Usuários do sistema com role e tenant_id |
| `tenants` | Clientes (organizações) |
| `products` | Produtos por tenant |
| `services` | Serviços por tenant |
| `contracts` | Contratos por tenant |
| `leads` | Leads por tenant |
| `audit_logs` | Logs de auditoria |
| `invoices` | Faturas por tenant |

### Row-Level Security (RLS)

O Supabase utiliza RLS para garantir isolamento de dados:
- `cliente_admin` e `cliente_user` só veem dados do próprio `tenant_id`
- `owner_admin` tem acesso global a todos os dados
- Políticas definidas em `supabase/migrations/001_initial_schema.sql`

### Criar Usuário Owner (Seed)

```sql
-- Execute no SQL Editor do Supabase
INSERT INTO auth.users (id, email, raw_user_meta_data)
VALUES (
  gen_random_uuid(),
  'admin@leadgenius.com',
  '{"name": "Super Admin", "role": "owner_admin"}'
);
```

## 🔐 Autenticação & Autorização

### Roles

| Role | Descrição | Acesso |
|------|-----------|--------|
| `owner_admin` | Super-admin | Todas as rotas |
| `owner_viewer` | Visualizador global | Leitura em rotas owner |
| `cliente_admin` | Admin do tenant | CRUD no próprio tenant |
| `cliente_user` | Usuário do tenant | Acesso limitado |

### Fluxo de Login

1. Usuário faz login com email/senha ou magic link
2. Sistema verifica role do usuário
3. Redireciona para área apropriada:
   - `owner_*` → `/owner/dashboard`
   - `cliente_*` → `/client/dashboard`

## 🛤️ Rotas

### Rotas de Autenticação
- `/login` - Tela de login
- `/register` - Tela de registro
- `/forgot-password` - Recuperação de senha

### Rotas de Cliente
- `/client/dashboard` - Dashboard do tenant
- `/client/leads` - Lista de leads
- `/client/leads/:id` - Detalhes do lead
- `/client/products` - Lista de produtos
- `/client/contracts` - Lista de contratos
- `/client/settings` - Configurações

### Rotas de Owner
- `/owner/dashboard` - Dashboard global
- `/owner/tenants` - Lista de tenants
- `/owner/tenants/:id` - Detalhes do tenant
- `/owner/users` - Gestão de usuários
- `/owner/audit` - Logs de auditoria
- `/owner/billing` - Faturamento

## 🧪 Testes

### Executar Testes

```bash
# Todos os testes
flutter test

# Testes com cobertura
flutter test --coverage

# Teste específico
flutter test test/services/lead_service_test.dart
```

## 📦 Build & Deploy

### Build APK (Android)

```bash
# APK debug
flutter build apk --debug

# APK release
flutter build apk --release

# App Bundle (para Play Store)
flutter build appbundle --release
```

### Build iOS

```bash
# Requer macOS
flutter build ios --release
```

### Build Web

```bash
flutter build web --release
```

### Build Windows

```bash
flutter build windows --release
```

## 🔄 CI/CD

O projeto inclui um workflow do GitHub Actions em `.github/workflows/flutter_ci.yml`:

- Roda em cada push/PR
- Executa análise de código (`flutter analyze`)
- Roda testes (`flutter test`)
- Gera build de verificação

## 📝 Licença

Este projeto é privado e proprietário.

---

## 🆘 Suporte

Para dúvidas ou problemas:
1. Verifique a configuração do Supabase
2. Confira as variáveis de ambiente
3. Verifique os logs do console

---

**Desenvolvido com ❤️ usando Flutter e Supabase**
