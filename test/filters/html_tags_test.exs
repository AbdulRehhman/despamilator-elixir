defmodule Despamilator.Filter.HtmlTagsTest do
  use ExUnit.Case, async: true
  import Despamilator.Test.FilterHelpers

  alias Despamilator.Filter.HtmlTags

  @tags ~w(
    !-- !DOCTYPE a abbr acronym address applet area b base basefont bdo big
    blockquote body br button caption center cite code col colgroup dd del
    dfn dir div dl dt em fieldset font form frame frameset h1 h2 h3 h4 h5
    h6 head hr html i iframe img input ins isindex kbd label legend li link
    map menu meta noframes noscript object ol optgroup option p param pre q
    s samp select small span strike strong style sub sup table tbody td
    textarea tfoot th thead title tr tt u ul var xmp
  )

  test "single match" do
    assert_filter_score(HtmlTags, "<xmp></xmp>", 0.6)
  end

  test "multiple distinct tags" do
    assert_filter_score(HtmlTags, "<h1></h1> <h2></h2>", 1.2)
  end

  test "same tag twice" do
    assert_filter_score(HtmlTags, "<div></div> <div></div>", 1.2)
  end

  for tag <- @tags do
    @tag_value tag

    test "detects #{tag} in many forms" do
      for cased <- [String.upcase(@tag_value), String.downcase(@tag_value)],
          variant <- [
            "<#{cased}>",
            "<#{cased}/>",
            "< #{cased} >",
            "<#{cased} />",
            "<\n#{cased}\n/>",
            "<\n#{cased} >",
            "<#{cased}\n/>",
            "<\r#{cased}\r/>"
          ] do
        assert_filter_score(HtmlTags, variant, 0.6)
      end
    end
  end
end
