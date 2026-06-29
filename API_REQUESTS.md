# TMJApp - Solicitacoes para API

Este documento resume o que o app passageiro (`tmjapp`) ainda precisa da API para fechar os fluxos novos sem depender de mock, workaround ou comportamento parcial.

## Status atual

Ja integrados no app:

- `POST /api/v2/auth/register`
- `POST /api/v2/auth/login`
- `POST /api/v2/auth/forgot-password`
- `POST /api/v2/auth/forgot-password/verify`
- `POST /api/v2/auth/reset-password`
- `GET /api/v2/passenger/rides`
- `POST /api/v2/passenger/rides`
- `PUT /api/v2/passenger/rides/:id/checkout`

## Prioridade 1 - Ride Request

Feature impactada:

- `lib/features/ride_request`

### 1. Cancelar corrida do passageiro

Necessidade:

- permitir cancelar a corrida depois da solicitacao
- hoje o app entra em `searchingDriver`, mas nao possui endpoint real para cancelamento

Sugestao de endpoint:

- `PATCH /api/v2/passenger/rides/:id/cancel`

Payload sugerido:

```json
{
  "reason": "passenger_changed_mind"
}
```

Resposta esperada:

```json
{
  "message": "Corrida cancelada com sucesso",
  "ride": {
    "id": "ride_id",
    "status": "canceled"
  }
}
```

### 2. Consultar status detalhado da corrida

Necessidade:

- acompanhar a transicao da corrida apos checkout
- hoje o app nao consegue sair de forma real de `searchingDriver`

Sugestao de endpoint:

- `GET /api/v2/passenger/rides/:id`

Resposta esperada:

```json
{
  "id": "ride_id",
  "status": "pending",
  "requested_at": "2026-03-12T20:00:00.000Z",
  "driver": {
    "id": "driver_id",
    "name": "Nome do motorista",
    "rating": 4.9,
    "phone_number": "81999999999",
    "photo_url": "https://..."
  },
  "vehicle": {
    "license_plate": "ABC1D23",
    "model": "Onix",
    "color": "Branco",
    "type": "Hatch"
  },
  "pickup_location": {
    "address": "Origem"
  },
  "destination_location": {
    "address": "Destino"
  },
  "product": {
    "id": "product_id",
    "name": "TMJ Comfort",
    "price": 18.5
  },
  "payment_method": "CARD"
}
```

### 3. Atualizacao de status em tempo real ou polling suportado

Necessidade:

- refletir os estados:
  - motorista encontrado
  - motorista chegou
  - viagem em andamento
  - viagem finalizada

Opcoes:

- endpoint de polling:
  - `GET /api/v2/passenger/rides/:id/status`
- ou contrato realtime oficial para passageiro

Resposta minima esperada:

```json
{
  "rideId": "ride_id",
  "status": "accepted",
  "updatedAt": "2026-03-12T20:05:00.000Z"
}
```

### 4. Token ou acesso realtime oficial para passageiro

Necessidade:

- acompanhar localizacao do motorista e ETA durante a corrida

Observacao:

- o repositorio da API ja possui documentacao de contratos Firebase realtime em `src/v2/docs/firebase`
- o app passageiro ainda nao consome isso

Solicitacao:

- formalizar endpoint/token para o app passageiro consumir os dados realtime com seguranca

## Prioridade 2 - Forgot Password

Feature impactada:

- `lib/features/forgot_password`

### 5. Corrigir envio de e-mail no forgot password

Necessidade:

- o fluxo do app esta integrado
- o backend falha no disparo do e-mail por SMTP

Erro observado:

- `ECONNREFUSED 127.0.0.1:587`

Solicitacao:

- revisar configuracao SMTP no ambiente `dev`
- garantir que `POST /api/v2/auth/forgot-password` realmente envie o codigo ao usuario

## Prioridade 3 - Payments

Feature impactada:

- `lib/features/payments`

### 6. Listagem real de metodos de pagamento do passageiro

Necessidade:

- hoje a tela deriva informacoes a partir das corridas
- nao existe consulta real de cartoes/metodos salvos

Sugestao de endpoint:

- `GET /api/v2/passenger/payments/methods`

Resposta esperada:

```json
{
  "methods": [
    {
      "id": "pm_1",
      "type": "card",
      "brand": "visa",
      "last4": "4432",
      "holderName": "Usuario TMJ",
      "isDefault": true
    },
    {
      "id": "pm_2",
      "type": "pix",
      "label": "PIX"
    }
  ]
}
```

### 7. Criar/remover metodo de pagamento

Sugestao de endpoints:

- `POST /api/v2/passenger/payments/methods`
- `DELETE /api/v2/passenger/payments/methods/:id`
- `PATCH /api/v2/passenger/payments/methods/:id/default`

## Prioridade 4 - Profile

Feature impactada:

- `lib/features/profile`

### 8. Upload de foto do passageiro

Necessidade:

- a tela de perfil hoje cobre leitura/edicao basica
- falta integracao de foto

Sugestao de endpoint:

- `POST /api/v2/passenger/profile/photo`

Resposta esperada:

```json
{
  "message": "Foto atualizada com sucesso",
  "photoUrl": "https://..."
}
```

### 9. Endereco principal e historico de enderecos

Necessidade:

- o app pode evoluir para enderecos salvos
- casa, trabalho e favoritos hoje nao sao vindos da API

Sugestao de endpoints:

- `GET /api/v2/passenger/profile/address`
- `PUT /api/v2/passenger/profile/address`
- `GET /api/v2/passenger/profile/address-history`
- `POST /api/v2/passenger/profile/address-history`

## Prioridade 5 - Onboarding

Feature impactada:

- `lib/features/onboarding`

### 10. Fechar integracao com status de onboarding

Necessidade:

- a API ja expoe onboarding status
- a feature ainda esta so visual no mobile

Endpoints a validar/usar:

- `GET /api/v2/auth/onboarding-status`
- `GET /api/v2/auth/onboarding-status/:id`

Resposta esperada:

- status dos passos necessarios para decidir navegacao e bloqueios iniciais do usuario

## Prioridade 6 - Notifications

Feature impactada:

- fluxo de notificacoes ainda legado

### 11. Centro de notificacoes do passageiro

Sugestao de endpoints:

- `GET /api/v2/passenger/notifications`
- `PATCH /api/v2/passenger/notifications/:id/read`
- `PATCH /api/v2/passenger/notifications/read-all`

Resposta esperada:

```json
{
  "items": [
    {
      "id": "notif_1",
      "title": "Motorista a caminho",
      "body": "Seu motorista chegara em 3 minutos",
      "read": false,
      "createdAt": "2026-03-12T20:10:00.000Z"
    }
  ],
  "unreadCount": 1
}
```

## Resumo para o backend

Ordem recomendada de entrega:

1. Cancelamento e consulta/status da corrida do passageiro
2. Correcao do SMTP no forgot password
3. Metodos de pagamento do passageiro
4. Foto e enderecos do perfil
5. Onboarding status consumivel pelo app
6. Notificacoes do passageiro

## Observacoes

- O app ja esta preparado para consumir novos endpoints por feature.
- A maior lacuna funcional hoje esta no fluxo da corrida apos o checkout.
- Se o backend optar por WebSocket ou Firebase Realtime para corrida em andamento, o ideal e formalizar um contrato unico para o app passageiro consumir.
