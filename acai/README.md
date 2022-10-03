### Acai (Gateway)

`port: 4000`

Gateway build on top of Phoenix Channels that will broadcast notifications, connecting user requests with dedicated
services

```shell
# startup
$ set PORT=4000&& iex --no-pry --sname gateway_node1 -S mix phx.server

# drop & clean setup
$ mix acai.reset
```