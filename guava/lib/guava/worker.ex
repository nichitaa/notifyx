defmodule Guava.Worker do
  use GenServer
  require Logger
  import Swoosh.Email
  alias Guava.WorkerDynamicSupervisor
  alias Guava.Mailer

  def start_link(args), do: GenServer.start_link(__MODULE__, args)

  ## Client API

  def send_mail(pid, mail_params), do: GenServer.call(pid, {:send_mail, mail_params})

  ## Callbacks 

  @impl true
  def init(init_args), do: {:ok, init_args}

  @impl true
  def handle_call(
        {:send_mail, %{"from" => from, "to" => to, "message" => message, "subject" => subject}},
        _from,
        state
      ) do
    log("send email to #{inspect(to)}")

    credentials =
      "oauth_refresh_token.json"
      |> File.read!()
      |> Jason.decode!()

    source = {
      :refresh_token,
      %{
        "refresh_token" => credentials["refresh_token"],
        "client_secret" => credentials["client_secret"],
        "client_id" => credentials["client_id"]
      },
      [
        scopes: ["https://mail.google.coom"]
      ]
    }

    # get Google OAuth access_token
    {:ok, %Goth.Token{token: access_token}} = Goth.Token.fetch(source: source)

    # compose & del
    response =
      new()
      |> to({to, to})
      |> from({from, from})
      |> subject(subject)
      # |> html_body("<h1>Hello</h1>")
      |> text_body(message)
      |> Mailer.deliver(access_token: access_token)

    # terminate worker process
    Process.send_after(self(), :terminate, 1000)

    {:reply, response, state}
  end

  @impl true
  def handle_info(:terminate, state) do
    log(":terminate")
    WorkerDynamicSupervisor.terminate_child(self())
    {:noreply, state}
  end

  defp log(text),
    do: Logger.info("[#{node()}] [#{__MODULE__}] [#{inspect(self())}] - #{inspect(text)}")
end
