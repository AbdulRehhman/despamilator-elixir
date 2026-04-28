defmodule Despamilator.Allowlist do
  @moduledoc """
  Allow-list of domains whose URLs should not be penalised by URL-aware filters.

  Configure via:

      config :despamilator,
        url_allowlist: [
          "pakwheels.com",
          "google.com",
          ~r/\\.(gov|edu)\\b/
        ]

  String entries match the host suffix (so `pakwheels.com` allows
  `www.pakwheels.com` and `forums.pakwheels.com`). Regex entries match
  anywhere in the lowercased host.

  Filters that consult the allow-list:

  * `Despamilator.Filter.URLs`
  * `Despamilator.Filter.IPAddressURL`
  * `Despamilator.Filter.VeryLongDomainName`
  * `Despamilator.Filter.SpammyTLDs`
  """

  @url_regex ~r{(https?://[^\s<>"']+)}i
  @host_regex ~r{https?://([^\s/?#]+)}i

  @doc "Returns the configured allow-list."
  def entries do
    Application.get_env(:despamilator, :url_allowlist, [])
  end

  @doc "True if `host` (e.g. `\"www.example.com\"`) is allow-listed."
  def host_allowed?(host) when is_binary(host) do
    h = String.downcase(host)
    Enum.any?(entries(), &entry_matches?(&1, h))
  end

  @doc """
  Returns `text` with every URL whose host is allow-listed replaced by a
  single space. Used by URL-aware filters to skip trusted domains entirely.
  """
  def strip(text) when is_binary(text) do
    case entries() do
      [] ->
        text

      _ ->
        Regex.replace(@url_regex, text, fn url ->
          if url_allowed?(url), do: " ", else: url
        end)
    end
  end

  defp url_allowed?(url) do
    case Regex.run(@host_regex, url, capture: :all_but_first) do
      [host] -> host_allowed?(host)
      _ -> false
    end
  end

  defp entry_matches?(entry, host) when is_binary(entry) do
    e = String.downcase(entry)
    host == e or String.ends_with?(host, "." <> e)
  end

  defp entry_matches?(%Regex{} = entry, host), do: Regex.match?(entry, host)
end
