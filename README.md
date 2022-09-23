### Notifyx (Notification system)

> Pasecinic Nichita
>
> Distributed systems

#### _Tech Stack_

* [`Elixir`](https://hexdocs.pm/elixir/Kernel.html)
* [`Phoenix` with `Channels`](https://hexdocs.pm/phoenix/overview.html) - WS API for Gateway and REST API for dedicated
  services
* [`Nebulex`](https://hexdocs.pm/nebulex/Nebulex.html) (for caching / service levels and gateway level)
* `Postgres` (will use [`Ecto`](https://hexdocs.pm/ecto/Ecto.html) as db wrapper
  with [`postrex`](https://github.com/elixir-ecto/postgrex) adapter)
* `React/TS` (client test application)
* ...

#### _What should be implemented (technically) ?_

* Authorization
* Caching at individual service & gateway level
* SQL databases for services
* `/dashboard` Status endpoint
* Tasks distributed across multiple requests
* Task timeouts per service tasks
* The Mailing service and Gateway could probably run on multiple nodes too
* The Gateway could load balance (RR) requests for the Mailing service nodes
* Real-time events/notifications via WS API and Phoenix Channels
* Service discovery for registering new services in the Gateway on their startup

#### _What should be implemented (business-wise) ?_

* User could send and receive notifications/messages in real-time
* Multiple & dynamic notifications topics created by users
* Service for persist and keep track of the broadcasted notifications, topics, subscriptions
* Service for sending notifications via email (if configured)
* Some time expensive tasks for either generating letter avatars [1](https://github.com/zhangsoledad/alchemic_avatar)
  for users, or integrate with unsplash API [2](https://github.com/waynehoover/unsplash-elixir) for searching images

[General architecture diagram](https://lucid.app/lucidchart/82c957a4-0db9-49d8-9f8b-dfd44882ce5e/edit?viewport_loc=199%2C-79%2C1993%2C784%2C0_0&invitationId=inv_80e2990b-1b1a-483e-8af2-38e5f92b85af#)


