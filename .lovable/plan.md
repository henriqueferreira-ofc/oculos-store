# Plano: Sistema profissional com backend, login e mobile

## Decisão sobre o backend

Você pediu pra usar **seu próprio Supabase com chave de API**. Isso **não é possível pela chave**: o Lovable só conecta Supabase via OAuth (botão Supabase no topo do chat, que só você consegue autorizar). 

A alternativa equivalente e que eu consigo ativar agora é o **Lovable Cloud** — é Supabase gerenciado pelo Lovable (mesmo banco PostgreSQL, mesmo Auth, mesmo Storage), sem você precisar mexer em conta externa nem chave. Vou seguir por esse caminho. Se mais tarde quiser mover pra sua instância Supabase própria, dá pra exportar.

## O que vou fazer

### 1. Ativar Lovable Cloud
Provisiona banco PostgreSQL, Auth (email/senha) e Storage automaticamente.

### 2. Banco de dados
Criar tabela `ordens_servico` no Postgres com todas as colunas que hoje vivem no `localStorage` (numero, nome, fone, valorTotal, lentes, armação, alt, cor, status, datas, etc.). RLS ativado: só admin autenticado lê/escreve.

### 3. Login admin email/senha
- Remover o gate de senha única atual e o endpoint `/api/public/auth`.
- Tela de login nova com **email + senha** usando Supabase Auth.
- Primeiro acesso: rota de cadastro habilitada **uma única vez** pra você criar o admin. Depois disso, cadastro fica bloqueado — só login.
- Sessão persistente, botão "Sair" funcional.

### 4. Migração dos dados antigos
Ao fazer login pela primeira vez, se houver OS no `localStorage` do navegador, mostro um botão **"Migrar dados antigos pro banco"** que envia tudo pro Postgres. Você confirma e os dados ficam salvos na nuvem (acessíveis de qualquer aparelho).

### 5. Mobile responsivo
- Header: logo menor, botões compactos com ícones, sem texto cortado.
- Cards de OS: empilhados em coluna única no celular, padding reduzido.
- Formulário: campos em coluna única abaixo de 640px, botões largura total.
- Tela de detalhe: layout adaptado, fontes ajustadas.
- Tela de login: card menor no celular.
- Testar em 375px (iPhone) e 414px.

## Detalhes técnicos

- App continua sendo o `public/app.html` (HTML estático servido). Vou adicionar o SDK `@supabase/supabase-js` via CDN — sem reescrever pra React.
- Funções `getDB/saveDB` viram chamadas async ao Supabase; loaders/spinners adicionados onde necessário.
- Endpoint `src/routes/api/public/auth.ts` removido (não mais usado).
- CSS: media queries `@media (max-width: 640px)` pra mobile.

## O que NÃO vou fazer agora
- Não vou conectar seu Supabase externo (só você consegue, pelo botão).
- Não vou criar múltiplos níveis de usuário (só admin único). Se quiser depois, dá pra adicionar.
