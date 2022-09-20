### Notifyx (Notification system)

> Pasecinic Nichita
>
> Distributed systems

#### _Tech Stack_

* `Elixir`
* `Phoenix` framework (WS API for Gateway / REST API for dedicated services)
* `:ets` (for Generic Cache services)
* `Postgres` (will use `Ecto` as db wrapper)
* `React/TS` (client test app)
* ...

#### _What should be implemented ?_

* Authorization
* User could send and receive notifications/messages via Phoenix Channels
* Multiple & dynamic notifications topics created by users
* Service for persist and keep track of the broadcasted notifications
* Generic Cache service (cache key a unique hash from: `session_id`, `req_method`, `req_path`, `req_payload` ..., and response data as value)
* Probably a service for sending notifications via email
* Probably a service discovery for registering new services in the Gateway on their startup

[General architecture diagram](https://lucid.app/lucidchart/82c957a4-0db9-49d8-9f8b-dfd44882ce5e/edit?viewport_loc=199%2C-79%2C1993%2C784%2C0_0&invitationId=inv_80e2990b-1b1a-483e-8af2-38e5f92b85af#)


