defmodule Acai.Utils.ReqUtils do
  def auto_retry(req_fn, opts \\ []) when is_function(req_fn) do
    number_of_retries = Keyword.get(opts, :number_of_retries, 3)

    auto_retry_poison_request(req_fn, number_of_retries)
  end

  defp auto_retry_poison_request(req_fn, number_of_retries, current_retry_no \\ 1) do
    response =
      case req_fn.() do
        {:ok, %HTTPoison.Response{} = res} ->
          handle_poison_ok(res)

        {:error, %HTTPoison.Error{} = res} ->
          {:retry, res}
      end

    case response do
      {:retry, error_response} ->
        if current_retry_no >= number_of_retries do
          {:retry_error, error_response}
        else
          auto_retry_poison_request(req_fn, number_of_retries, current_retry_no + 1)
        end

      {:ok, ok_response} ->
        {:ok, ok_response}

      {:error, error_response} ->
        {:error, error_response}
    end
  end

  defp handle_poison_ok(%HTTPoison.Response{} = response) do
    case response do
      %HTTPoison.Response{status_code: status_code, body: body}
      when status_code in 200..300 ->
        map = Enum.into(response.headers, %{}, fn {k, v} -> {String.downcase(k), v} end)

        content_type = Map.get(map, "content-type", "")

        reply_data =
          if String.contains?(content_type, "application/json") do
            Jason.decode!(body)
          else
            body
          end

        {:ok, reply_data}

      %HTTPoison.Response{status_code: 500} = error_response ->
        {:retry, error_response}

      _ ->
        {:error, response}
    end
  end
end
