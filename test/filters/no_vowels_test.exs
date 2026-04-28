defmodule Despamilator.Filter.NoVowelsTest do
  use ExUnit.Case, async: true
  import Despamilator.Test.FilterHelpers

  alias Despamilator.Filter.NoVowels

  test "single match" do
    assert_filter_score(
      NoVowels,
      "Try The lazy brown fox jumped 25 times over http://www.google.com.au for a gthrrt",
      0.01
    )
  end

  test "two matches" do
    assert_filter_score(
      NoVowels,
      "The lazy brown fox jumped 25 times gthrrt over http://www.google.com.au for a gthrrt",
      0.04
    )
  end

  test "five matches" do
    assert_filter_score(
      NoVowels,
      "kjmnllpw wstrtffg The lazy brown  fox jumped 25 ffgfvvfvr times over gthrrt http://www.google.com.au for a gthrrt ",
      0.25
    )
  end
end
