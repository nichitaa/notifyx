defmodule Notification do
  @enforce_keys [:message, :to]
  @derive Jason.Encoder
  defstruct [:message, :from, :to]

  def new(message, from, to) do
    %Notification{message: message, from: from, to: to}
  end
end
