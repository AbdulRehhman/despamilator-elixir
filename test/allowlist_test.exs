defmodule Despamilator.AllowlistTest do
  use ExUnit.Case, async: false

  alias Despamilator.Allowlist
  alias Despamilator.Filter.{IPAddressURL, SpammyTLDs, URLs, VeryLongDomainName}

  import Despamilator.Test.FilterHelpers

  setup do
    on_exit(fn -> Application.delete_env(:despamilator_elixir, :url_allowlist) end)
    :ok
  end

  describe "host_allowed?/1" do
    test "exact match" do
      Application.put_env(:despamilator_elixir, :url_allowlist, ["pakwheels.com"])
      assert Allowlist.host_allowed?("pakwheels.com")
    end

    test "subdomain match" do
      Application.put_env(:despamilator_elixir, :url_allowlist, ["pakwheels.com"])
      assert Allowlist.host_allowed?("www.pakwheels.com")
      assert Allowlist.host_allowed?("forums.pakwheels.com")
    end

    test "non-match" do
      Application.put_env(:despamilator_elixir, :url_allowlist, ["pakwheels.com"])
      refute Allowlist.host_allowed?("evilpakwheels.com")
      refute Allowlist.host_allowed?("evil.com")
    end

    test "regex entry" do
      Application.put_env(:despamilator_elixir, :url_allowlist, [~r/\.gov$/])
      assert Allowlist.host_allowed?("foo.gov")
      assert Allowlist.host_allowed?("data.foo.gov")
      refute Allowlist.host_allowed?("foo.gov.evil.com")
    end

    test "case-insensitive" do
      Application.put_env(:despamilator_elixir, :url_allowlist, ["PakWheels.com"])
      assert Allowlist.host_allowed?("WWW.pakwheels.COM")
    end
  end

  describe "URLs filter respects allowlist" do
    test "allowlisted url scores zero" do
      Application.put_env(:despamilator_elixir, :url_allowlist, ["pakwheels.com"])
      assert_filter_score(URLs, "Visit https://www.pakwheels.com/listings", 0)
    end

    test "non-allowlisted url still scores" do
      Application.put_env(:despamilator_elixir, :url_allowlist, ["pakwheels.com"])
      assert_filter_score(URLs, "Visit https://evil.sbs/x", 0.4)
    end

    test "mixed: only non-allowlisted urls counted" do
      Application.put_env(:despamilator_elixir, :url_allowlist, ["pakwheels.com"])

      assert_filter_score(
        URLs,
        "https://www.pakwheels.com/a https://evil.sbs/x https://other.com/y",
        0.8
      )
    end
  end

  describe "other URL filters respect allowlist" do
    test "IPAddressURL skipped for allowlisted ip" do
      Application.put_env(:despamilator_elixir, :url_allowlist, [~r/^12\.34\.56\.78$/])
      assert_filter_score(IPAddressURL, "go to http://12.34.56.78/", 0)
    end

    test "VeryLongDomainName skipped" do
      Application.put_env(:despamilator_elixir, :url_allowlist, ["cje6cgsllk-0ds3nnto7dj.com"])

      assert_filter_score(
        VeryLongDomainName,
        "blah http://cje6CgslLk-0ds3Nnto7dj.com blah",
        0
      )
    end

    test "SpammyTLDs skipped" do
      Application.put_env(:despamilator_elixir, :url_allowlist, ["blahdee.biz"])
      assert_filter_score(SpammyTLDs, "http://www.blahdee.biz", 0)
    end
  end
end
