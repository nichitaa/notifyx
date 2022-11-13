### Notifyx (Notification system)

> Pasecinic Nichita
>
> Distributed systems

#### _Tech Stack_

* [`Elixir`](https://hexdocs.pm/elixir/Kernel.html)
* [`NodeJS`](https://nodejs.org/en/) - [`expressjs`](https://expressjs.com/)
* [`Phoenix`](https://hexdocs.pm/phoenix/overview.html) with [`Channels`](https://hexdocs.pm/phoenix/channels.html) - WS
  API for Gateway and REST API for dedicated
  services
* [`Nebulex`](https://hexdocs.pm/nebulex/Nebulex.html) (for caching / service levels and gateway level)
* [`Postgres`](https://www.postgresql.org/) (will use [`Ecto`](https://hexdocs.pm/ecto/Ecto.html) as db wrapper
  with [`postrex`](https://github.com/elixir-ecto/postgrex) adapter)
* [`React/TS`](https://reactjs.org/) (client test application)
* [`Prometheus`](https://prometheus.io/docs/introduction/overview/) (for metrics scraping)
* [`Grafana`](https://grafana.com/docs/) (for visual metrics monitoring)
* [`Docker`](https://docs.docker.com/compose/) (`docker-compose` for CI/deployment)

#### _[Naming is hard](https://quotesondesign.com/phil-karlton/)_

Each service / component will be in a dedicated folder ⚙

* [`acai`](./acai) - Gateway with Phoenix Channels (`port: 4000`)
* [`durian`](./durian) - Auth Service (`port: 5000`)
* [`kiwi`](./kiwi) - Persistent Service (`port: 6000`)
* [`counter_2pc`](./counter_2pc) - Users notifications counter (with 2 phase commit support) (`port: 2000`)
* [`client`](./client) - Client test application (`port: 3333`)
* [`guava`](./guava) - Mailing Service (`port: 7000`)
* [`julik`](./julik) - Service Discovery (`port: 8000`)
* [`nodex`](./nodex) - Service for generating random stuff (avatars FN) (`port:9000`)
* [`monitoring`](./monitoring) - Monitoring tools configuration (grafana - `port: 3000`,
  prometheus: `port: 9090`) - [Dashboards screenshots](./monitoring/README.md)

### Dev Notes 👀

#### Docker setup 🐳

```shell
docker compose up --build --force-recreate
```

```shell
# For cleaning up previous Docker images/containers/volumes (run in PowerShell)
# Don't need to run them on first setup
docker rmi -f $(docker images -aq)
docker rm -f $(docker ps -a -q)
docker volume rm $(docker volume ls -q)
```

#### Manual setup ⚙

[Start Grafana & Prometheus Stack as separate Docker containers](./monitoring/README.md)

```shell
cd monitoring\local
docker compose up --build
```

```shell
# 1. Start Gateway (acai)
cd acai && set PORT=4000&& iex --no-pry --sname gateway_node1 -S mix phx.server

# 2. Start Service Discovery (julik)
cd julik && set PORT=8000&& iex --no-pry --sname discovery_node1 -S mix phx.server

# 3. Start Auth Service (durian)
cd durian && set PORT=5000&& iex --no-pry --sname auth_node1 -S mix phx.server
cd durian && set PORT=5001&& iex --no-pry --sname auth_node2 -S mix phx.server

# 4. Start Persist Service (kiwi)
cd kiwi && set PORT=6000&& iex --no-pry --sname persist_node1 -S mix phx.server

# 5. Start Mail Service Cluster (guava)
cd guava && set ENABLE_REST_API=1& set PORT=7000&& iex --no-pry --sname mail_node1 -S mix phx.server
cd guava && set PORT=7001&& iex --no-pry --sname mail_node2 -S mix phx.server
cd guava && set PORT=7002&& iex --no-pry --sname mail_node3 -S mix phx.server
cd guava && set PORT=7003&& iex --no-pry --sname mail_node4 -S mix phx.server

# 6. Start Generator Service Cluster (nodex)
cd nodex && npm run dev:pm2
# to stop: npm run del:pm2

# 7. Start Counter 2 Phase commit service (counter_2pc)
cd counter_2pc && set PORT=2000& iex --no-pry --sname counter_2pc -S mix phx.server

# 8. Start Client application (client)
cd client && npm run dev
```

#### _What should be implemented (technically) ?_

Service Features:

* SQL databases (postgres) - (Auth & Persist service)
* Status endpoint `/dashboard` - Generated by Phoenix Framework
* Task timeouts configurable per individual task - e.g.: inside `config.exs` - `send_email_timeout: 1000`
* Service Discovery - [`julik`](./julik)
* RPC - Mailing service Nodes communicates via [`:erpc`](https://www.erlang.org/doc/man/erpc.html)
* Concurrent task limit - `DynamicSupervisor` for mail workers has a `max_children`
  configured <sup>[link](./guava/config/config.exs)</sup>
* Grafana / Prometheus metrics collection & monitoring
* 2 phase commit for create notification action (`kiwi` & `counter_2pc`)
    * `POST` - `/api/notifications` with `is_2pc_locked: true` (prepare)
    * `POST` - `/api/notifications/commit_2pc` with `request_id` from prepare step (commit)
    * `DELETE` - `/api/notifications/rollback_2pc` with `request_id` from prepare step (rollback)

Gateway Features:

* Load Balancing - Round Robin
* Outbound WS API
* Circuit breaker <sup>[link](./acai/lib/acai/circuit_breaker.ex)</sup>
* Grafana / Prometheus metrics collection & monitoring
* 2 phase commit integration for services that supports it
    * 1 phase - prepare data request -> success/error
    * 2 phase - commit/rollback request -> ack/nack

The Cache:

* Implemented in Auth Service
* Implemented in Persist Service
* Replicated cache (across all Auth service nodes - `durian` nodes)

Other:

* Real-time events/notifications via WS API and Phoenix Channels

#### _Some 2 Phase commit implementation notes_

Services should implement several routes for it:

* `POST` - `/api/prepare_2pc`
* `POST` - `/api/commit_2pc`
* `DELETE` - `/api/rollback_2pc`

After successful `prepare` request it might return an identifier for the created transaction (mutation) or ack/nack:

* `kiwi` - will return `request_id` (later used to rollback/commit transaction)
* `counter_2pc` - just ack (`user_id` from request is enough to rollback/commit transaction)

Actually the terminology of `commit/rollback transaction` should be better called `save/discard data actions`. As there
is no
real transaction reference that could be later used to commit/rollback it, the data is still persisted somewhere and
there
should exist a clean-up/save handlers for each of the atomic change

#### The [`Manager2PC`](./acai/lib/services/manager_2pc.ex)

Is the generic implementation for handling first and second phase from 2 phase-commit requests.
The prepare phase is domain specific, meaning that it should be clearly defined all prepare tasks handlers like:

```elixir
prepare_tasks = [
  Task.async(fn ->
    Services.Persist.init_2pc(socket, notification)
  end),
  Task.async(fn ->
    Services.Counter.init_2pc(socket)
  end)
]
```

`init_2pc` function should return a tuple of:

```elixir
{:ok, commit_fn, rollback_fn}
{:error, data}
```

`commit_fn` and `rollback_fn` are as well domain specific so those should be handled by the dedicated services
separately.

The second phase is executing either `commit_fn` or `rollback_fn` handlers, based on response from prepare (first)
phase.
A big disadvantage of 2 phase commit approach is that there is no clear definition of what should happen when a task
from second phase
fails (either to commit or rollback).

Note that tasks from both phases are done asynchronously with `Task.async/1` and awaited with `Task.await_many/2`.

#### _What should be implemented (business-wise) ?_

* User could send, receive, ack notifications/messages in real-time
* Multiple & dynamic notifications topics created by users (all other operations will validate topic creators)
* Service for persist and keep track of the broadcasted notifications, topics, subscriptions
* Service for sending notifications via email
* Service for generating PNG avatars

[General architecture diagram](https://lucid.app/lucidchart/82c957a4-0db9-49d8-9f8b-dfd44882ce5e/edit?viewport_loc=199%2C-79%2C1993%2C784%2C0_0&invitationId=inv_80e2990b-1b1a-483e-8af2-38e5f92b85af#)


