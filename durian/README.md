### Durian (Authorization API)

Phoenix Application

```shell
$ mix phx.new durian --database postgres --no-assets --no-html --no-gettext --no-live --no-mailer --binary-id --verbose
```

New `JSON` resource & context

```shell

$ mix phx.gen.json Auth User users email:string hashed_password:string token:string expiry:utc_datetime
```

For the first start

```shell
$ mix deps.get
$ mix ecto.setup
$ iex --no-pry -S mix phx.server
```

Drop & new

```shell
$ mix ecto.drop --force-drop
$ mix ecto.setup
```