defmodule Despamilator.Subject do
  @moduledoc """
  The mutable-feeling accumulator for a scan. Holds the original `text`,
  the running `score`, and per-filter score totals in `match_scores`.
  """

  alias Despamilator.Subject.Text

  @type t :: %__MODULE__{
          text: String.t(),
          score: float(),
          match_scores: %{module() => float()},
          match_order: [module()]
        }

  defstruct text: "", score: 0.0, match_scores: %{}, match_order: []

  @doc "Builds a new subject from raw text."
  def new(text) when is_binary(text) do
    %__MODULE__{text: text, score: 0.0, match_scores: %{}, match_order: []}
  end

  @doc """
  Records a match. Filter is the implementing module; score is added to both
  the per-filter total and the subject's running score.
  """
  def register_match(%__MODULE__{} = subject, filter, score)
      when is_atom(filter) and is_number(score) do
    new_total = Map.get(subject.match_scores, filter, 0.0) + score * 1.0

    order =
      if Map.has_key?(subject.match_scores, filter),
        do: subject.match_order,
        else: subject.match_order ++ [filter]

    %{
      subject
      | score: subject.score + score * 1.0,
        match_scores: Map.put(subject.match_scores, filter, new_total),
        match_order: order
    }
  end

  @doc """
  Returns matches as a list of `%{filter: module, score: float}` maps,
  sorted highest score first (ties keep insertion order).
  """
  def matches(%__MODULE__{match_scores: scores, match_order: order}) do
    order
    |> Enum.map(fn f -> %{filter: f, score: Map.fetch!(scores, f)} end)
    |> Enum.sort_by(& &1.score, :desc)
  end

  @doc "Convenience: hand the subject text to a `Despamilator.Subject.Text` helper."
  def text(%__MODULE__{text: t}), do: t

  defdelegate without_uris(text), to: Text
  defdelegate words(text), to: Text
  defdelegate count(text, pattern), to: Text
  defdelegate remove_and_count(text, pattern), to: Text
end
