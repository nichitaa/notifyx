# Kiwi (Persistent Service)

```shell
$ mix phx.gen.json Persist Topic topics name:string:unique created_by:integer longevity:integer status:enum:active:inactive
$ mix phx.gen.json Persist Notification notifications message:string from:integer topic_id:references:topics seen_by:array:integer to:array:integer
```