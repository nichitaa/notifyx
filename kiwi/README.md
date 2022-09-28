# Kiwi (Persistent Service)

Gen JSON resource
```shell
$ mix phx.gen.json Persist Topic topics name:string:unique created_by:integer longevity:integer status:enum:active:inactive
$ mix phx.gen.json Persist Notification notifications message:string from:integer topic_id:references:topics seen_by:array:integer to:array:integer
```

Startup
```shell
$ iex --sname node1 --no-pry -S mix phx.server
```