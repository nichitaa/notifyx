defmodule Acai.Utils.ReqUtils do
  def auto_retry(req_fn, opts \\ []) when is_function(req_fn) do
    number_of_retries = Keyword.get(opts, :number_of_retries, 3)

    auto_retry_poison_request(req_fn, number_of_retries)
  end

  defp auto_retry_poison_request(req_fn, number_of_retries, current_retry_no \\ 1) do
    response =
      case req_fn.() do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          json = Jason.decode!(body)
          {:ok, json}

        {:ok, %HTTPoison.Response{status_code: 500} = error_response} ->
          {:error, error_response}

        {:error, error} ->
          {:error, error}

        _ ->
          {:error, "unhandled error"}
      end

    case response do
      {:ok, success_json} ->
        {:ok, success_json}

      {:error, error_response} ->
        if current_retry_no >= number_of_retries do
          {:error, error_response}
        else
          auto_retry_poison_request(req_fn, number_of_retries, current_retry_no + 1)
        end
    end
  end
end
