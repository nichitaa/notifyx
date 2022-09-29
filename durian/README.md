### Durian (Authorization API)

`port: 5000`


```shell
# startup
$ set PORT=5000&& iex --no-pry --sname auth_node1 -S mix phx.server

# drop & clean setup
$ mix durian.reset
```