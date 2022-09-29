### Notifyx (Notification system)

> Pasecinic Nichita
>
> Distributed systems

#### _Tech Stack_

* [`Elixir`](https://hexdocs.pm/elixir/Kernel.html)
* [`Phoenix`](https://hexdocs.pm/phoenix/overview.html) with [`Channels`](https://hexdocs.pm/phoenix/channels.html) - WS API for Gateway and REST API for dedicated
  services
* [`Nebulex`](https://hexdocs.pm/nebulex/Nebulex.html) (for caching / service levels and gateway level)
* `Postgres` (will use [`Ecto`](https://hexdocs.pm/ecto/Ecto.html) as db wrapper
  with [`postrex`](https://github.com/elixir-ecto/postgrex) adapter)
* [`React/TS`](https://reactjs.org/) (client test application)
* ...

#### _[Naming is hard](https://quotesondesign.com/phil-karlton/)_
Each service / component will be in a dedicated folder
* [`acai`](./acai) - Gateway with Phoenix Channels
* [`durian`](./durian) - Auth Service
* [`kiwi`](./kiwi) - Persistent Service (and business logic)
* [`client`](./client) - Client test application
* [`guava`](./guava) - Mailing Service
* ...

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


