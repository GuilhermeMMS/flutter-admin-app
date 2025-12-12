# Lead Genius Admin

Aplicativo Flutter multi-tenant com Firebase para gerenciamento de leads, produtos, serviços e contratos.

## 🚀 Tecnologias

- **Flutter 3.x** - Framework UI
- **Firebase** - Backend (Auth, Firestore, Storage)
- **Riverpod** - Gerenciamento de estado
- **GoRouter** - Navegação com guards
- **Material 3** - Design system

## 📁 Estrutura do Projeto

```
lib/
├── app/                    # Configuração do app
│   ├── app.dart           # Widget raiz
│   ├── routes.dart        # Configuração de rotas
│   ├── theme.dart         # Tema Material 3
│   └── constants.dart     # Constantes globais
├── core/
│   ├── providers/         # Providers Riverpod
│   ├── guards/            # Guards de rota
│   └── errors/            # Exceções customizadas
├── models/                # Modelos de dados
├── services/              # Serviços (Firebase)
├── pages/                 # Telas do app
│   ├── auth/              # Login, Registro, Recuperação
│   ├── client/            # Área do cliente
│   └── owner/             # Área do super-admin
├── widgets/               # Componentes reutilizáveis
└── utils/                 # Utilitários
```

## 🔐 Roles (RBAC)

| Role | Descrição |
|------|-----------|
| `owner_admin` | Super-admin com acesso total |
| `owner_viewer` | Super-admin apenas leitura |
| `cliente_admin` | Admin do tenant |
| `cliente_user` | Usuário comum do tenant |

## 🔥 Configuração do Firebase

### 1. Criar projeto no Firebase Console

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Crie um novo projeto
3. Ative **Authentication** (Email/Password)
4. Ative **Cloud Firestore**
5. Ative **Storage** (opcional)

### 2. Configurar Flutter

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar projeto (na pasta do projeto)
flutterfire configure
```

### 3. Adicionar regras do Firestore

Copie o conteúdo de `firebase/firestore.rules` para:
Firebase Console > Firestore Database > Rules

### 4. Criar usuário admin

No Firebase Console > Authentication:
1. Adicione um usuário com email/senha
2. Copie o UID do usuário

No Firebase Console > Firestore:
1. Crie a coleção `users`
2. Adicione um documento com o UID:

```json
{
  "id": "UID_DO_USUARIO",
  "email": "admin@email.com",
  "name": "Super Admin",
  "role": "owner_admin",
  "is_active": true,
  "created_at": "2024-01-01T00:00:00Z"
}
```

## 🏃 Executar

```bash
# Instalar dependências
flutter pub get

# Executar no Chrome (web)
flutter run -d chrome

# Executar em dispositivo conectado
flutter run

# Build de produção
flutter build web
flutter build apk
```

## 📱 Funcionalidades

### Área do Cliente
- ✅ Dashboard com métricas
- ✅ Gestão de Leads (CRUD)
- ✅ Gestão de Produtos (CRUD)
- ✅ Gestão de Serviços (CRUD)
- ✅ Gestão de Contratos (CRUD)
- ✅ Relatórios
- ✅ Configurações

### Área do Owner
- ✅ Dashboard global
- ✅ Gestão de Tenants
- ✅ Gestão de Usuários
- ✅ Logs de Auditoria
- ✅ Ferramentas de Suporte
- ✅ Faturamento

## 📝 Licença

Este projeto é privado.
