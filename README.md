### Notifyx (Notification system)

> Pasecinic Nichita
>
> Distributed systems

#### _Tech Stack_

* [`Elixir`](https://hexdocs.pm/elixir/Kernel.html)
* [`NodeJS`](https://nodejs.org/en/) - [`expressjs`](https://expressjs.com/)
* [`Phoenix`](https://hexdocs.pm/phoenix/overview.html) with [`Channels`](https://hexdocs.pm/phoenix/channels.html) - WS API for Gateway and REST API for dedicated
  services
* [`Nebulex`](https://hexdocs.pm/nebulex/Nebulex.html) (for caching / service levels and gateway level)
* `Postgres` (will use [`Ecto`](https://hexdocs.pm/ecto/Ecto.html) as db wrapper
  with [`postrex`](https://github.com/elixir-ecto/postgrex) adapter)
* [`React/TS`](https://reactjs.org/) (client test application)
* ...

#### _[Naming is hard](https://quotesondesign.com/phil-karlton/)_ 
Each service / component will be in a dedicated folder ⚙
* [`acai`](./acai) - Gateway with Phoenix Channels (`port: 4000`)
* [`durian`](./durian) - Auth Service (`port: 5000`)
* [`kiwi`](./kiwi) - Persistent Service (`port: 6000`)
* [`client`](./client) - Client test application (`port: 3000`)
* [`guava`](./guava) - Mailing Service (`port: 7000`)
* [`julik`](./julik) - Service Discovery (`port: 8000`)
* [`nodex`](./nodex) - Service for generating random stuff (avatars FN) (`port:9000`)
* ...

### Dev Notes 👀
```shell
# 1. Start Gateway (acai)
set PORT=4000&& iex --no-pry --sname gateway_node1 -S mix phx.server

# 2. Start Service Discovery (julik)
set PORT=8000&& iex --no-pry --sname discovery_node1 -S mix phx.server

# 3. Start Auth Service (durian)
set PORT=5000&& iex --no-pry --sname auth_node1 -S mix phx.server

# 4. Start Persist Service (kiwi)
set PORT=6000&& iex --no-pry --sname persist_node1 -S mix phx.server

# 5. Start Mail Service Cluster (guava)
set ENABLE_REST_API=1& set PORT=7000&& iex --no-pry --sname mail_node1 -S mix phx.server
set PORT=7001&& iex --no-pry --sname mail_node2 -S mix phx.server
set PORT=7002&& iex --no-pry --sname mail_node3 -S mix phx.server
set PORT=7003&& iex --no-pry --sname mail_node4 -S mix phx.server

# 6. Start Generator Service Cluster (nodex)
npm run start:pm2
# to stop: npm run del:pm2

# 7. Start Client application (client)
npm run dev
```

#### _What should be implemented (technically) ?_

* Authorization
* Caching at individual service & gateway level
* SQL databases for services
* `/dashboard` Status endpoint
* Tasks distributed across multiple requests
* Task timeouts per service tasks
* The Mailing service and Gateway could probably run on multiple nodes too
* The Gateway could load balance (via round-robin) requests for the Mailing service nodes (or Main node in Mailing service could do it)
* Real-time events/notifications via WS API and Phoenix Channels
* Service discovery for registering new services in the Gateway on their startup
* Mailing Service will expose REST API for Gateway, but Nodes internally will communicate via [`:erpc`](https://www.erlang.org/doc/man/erpc.html)

#### _What should be implemented (business-wise) ?_

* User could send, receive, ack notifications/messages in real-time
* Multiple & dynamic notifications topics created by users (all other operations will validate topic creators)
* Service for persist and keep track of the broadcasted notifications, topics, subscriptions
* Service for sending notifications via email (if configured)
* Mb will invent some time expensive tasks that would not require a datasource and could be easily separated & distributed

[General architecture diagram](https://lucid.app/lucidchart/82c957a4-0db9-49d8-9f8b-dfd44882ce5e/edit?viewport_loc=199%2C-79%2C1993%2C784%2C0_0&invitationId=inv_80e2990b-1b1a-483e-8af2-38e5f92b85af#)


