### Guava (Mail Service)

`port: 7000`

```shell
# start parent Node that exposes the client API
$ set ENABLE_REST_API=1& set PORT=7000&& iex --no-pry --sname mail_node1 -S mix phx.server

# start child Nodes in cluster (must be on different ports)
$ set PORT=7001&& iex --no-pry --sname mail_node2 -S mix phx.server
$ set PORT=7002&& iex --no-pry --sname mail_node3 -S mix phx.server
$ set PORT=7003&& iex --no-pry --sname mail_node4 -S mix phx.server
```

req -> get_node [balancer] -> rpc -> DynamicWorkerPool -> task -> response