defmodule Despamilator.Filter.VeryLongDomainNameTest do
  use ExUnit.Case, async: true
  import Despamilator.Test.FilterHelpers

  alias Despamilator.Filter.VeryLongDomainName

  test "single long domain" do
    assert_filter_score(
      VeryLongDomainName,
      "blah http://cje6CgslLk-0ds3Nnto7dj.com blah",
      0.4
    )
  end

  test "two long domains" do
    assert_filter_score(
      VeryLongDomainName,
      "blah http://cje6CgslLk0ds3Nnto7dj.com?x=jkhkh345kjhkhkj43h5jhjh45 blah http://cje6CgslLk0ds3Nnto7dj.com",
      0.8
    )
  end

  test "ignores subdomains" do
    assert_filter_score(VeryLongDomainName, "http://www.gretchenmist.blogspot.com", 0)
  end
end
