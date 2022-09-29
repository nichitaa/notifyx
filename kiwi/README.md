# Kiwi (Persistent Service)

`port: 6000`

```shell
# startup
$ set PORT=6000&& iex --no-pry --sname persist_node1 -S mix phx.server

# drop & clean setup
$ mix kiwi.reset
```
