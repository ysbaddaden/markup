require 'test_helper'

class InlinesTest < ActiveSupport::TestCase
  test "should parse bold" do
    assert_equal [[:p, [ "lorem ipsum ", [:b, "dolor sit"], " amet" ]]],
      Markup.new("lorem ipsum **dolor sit** amet").parse
  end

  test "should parse italic" do
    assert_equal [[:p, [ "lorem ", [:i, "ipsum"], " dolor sit amet" ]]],
      Markup.new("lorem //ipsum// dolor sit amet").parse
  end

  test "should parse underline" do
    assert_equal [[:p, [ "lorem ", [:u, "ipsum"], " dolor sit amet" ]]],
      Markup.new("lorem __ipsum__ dolor sit amet").parse
  end

  test "should parse code" do
    assert_equal [[:p, [ "lorem ", [:code, "ipsum"], " dolor sit amet" ]]],
      Markup.new("lorem `ipsum` dolor sit amet").parse
  end

  test "should not parse within code" do
    assert_equal [[:p, [ "lorem ", [:code, "ipsum **dolor** sit"], " amet" ]]],
      Markup.new("lorem `ipsum **dolor** sit` amet").parse
  end

  test "should parse strikethrough" do
    assert_equal [[:p, [ "lorem ", [:s, "ipsum"], " dolor sit amet" ]]],
      Markup.new("lorem ~~ipsum~~ dolor sit amet").parse
  end

  test "should parse bold within italic" do
    assert_equal [[:p, [ "lorem ", [:i, ["ipsum ", [:b, "dolor sit"]]], " amet" ]]],
      Markup.new("lorem //ipsum **dolor sit**// amet").parse
  end

  test "should parse italic within bold" do
    assert_equal [[:p, [[:b, [[:i, "lorem ipsum"], " dolor"]], " sit amet"] ]],
      Markup.new("**//lorem ipsum// dolor** sit amet").parse
  end

  test "should parse bold and italic within list items" do
    assert_equal [[ :ul, [ [:li, [[:b, "item"], " 1"]], [:li, [[:i, "item"], " 2"]] ] ]],
      Markup.new("- **item** 1\n- //item// 2").parse
  end


  test "should parse link" do
    assert_equal [[:p, [ :a, { :href => "http://www.wikicreole.org/" }, [ "http://www.wikicreole.org/" ] ]]],
      Markup.new("[[http://www.wikicreole.org/]]").parse
  end

  test "should parse links" do
    struct = [[:p, [
      "This is a link ",
      [:a, { :href => "http://www.wikicreole.org/" }, [ "http://www.wikicreole.org/" ]],
      " and another one ",
      [:a, { :href => "http://rubygems.org" }, [ "http://rubygems.org" ]],
      "."
    ] ]]
    
    assert_equal struct,
      Markup.new("This is a link [[http://www.wikicreole.org/]] and another one [[http://rubygems.org]].").parse
  end
end
