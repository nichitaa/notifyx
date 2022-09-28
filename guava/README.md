# Guava (Mail Service)

```shell
# start parent Node that exposes the client API
$ set ENABLE_REST_API=1& set PORT=4000&& iex --no-pry --sname node1 -S mix phx.server

# start child Nodes in cluster (must be on different ports)
$ set PORT=4001&& iex --no-pry --sname node2 -S mix phx.server
$ set PORT=4002&& iex --no-pry --sname node3 -S mix phx.server
$ set PORT=4003&& iex --no-pry --sname node4 -S mix phx.server
```

req -> get_node [balancer] -> rpc -> DynamicWorkerPool -> task -> response