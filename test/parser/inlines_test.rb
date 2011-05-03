require 'test_helper'

class InlinesTest < ActiveSupport::TestCase
  test "should parse bold" do
    assert_equal [[:p, [ "lorem ipsum ", [:b, "dolor sit"], " amet" ]]],
      Markup.new("lorem ipsum **dolor sit** amet").parse
    
    assert_equal [[:p, [ "lorem ipsum ", [:b, "dolor sit"], ", amet" ]]],
      Markup.new("lorem ipsum **dolor sit**, amet").parse
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
    
    assert_equal [[:p, [ "lorem ", [:code, "ipsum"], ", ", [:code, "dolor"], ", sit ", [:code, "amet"] ]]],
      Markup.new("lorem `ipsum`, `dolor`, sit `amet`").parse
  end

  test "should not parse within code" do
    assert_equal [[:p, [ "lorem ", [:code, "ipsum **dolor** sit"], " amet" ]]],
      Markup.new("lorem `ipsum **dolor** sit` amet").parse
  end

  test "should parse strikethrough" do
    assert_equal [[:p, [ "lorem ", [:s, "ipsum"], " dolor sit amet" ]]],
      Markup.new("lorem ~~ipsum~~ dolor sit amet").parse
  end

  test "should parse superscript" do
    assert_equal [[:p, [[:sup, "lorem ipsum dolor"], " sit amet" ]]],
      Markup.new("^^lorem ipsum dolor^^ sit amet").parse
  end

  test "should parse subscript" do
    assert_equal [[:p, [[:sub, "lorem ipsum dolor"], " sit amet" ]]],
      Markup.new(",,lorem ipsum dolor,, sit amet").parse
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
    assert_equal [[:p, [[:a, "http://www.wikicreole.org/", { :href => "http://www.wikicreole.org/" } ]]]],
      Markup.new("[[http://www.wikicreole.org/]]").parse
  end

  test "should parse link with contents" do
    assert_equal [[:p, [[:a, "Creole 1.0", { :href => "http://www.wikicreole.org/" } ]]]],
      Markup.new("[[http://www.wikicreole.org/|Creole 1.0]]").parse
  end

  test "should parse bold link" do
    assert_equal [[:p, [[:b, [[ :a, "Creole 1.0", { :href => "http://www.wikicreole.org/" } ]]]]]],
      Markup.new("**[[http://www.wikicreole.org/|Creole 1.0]]**").parse
  end

  test "should parse links" do
    struct = [[:p, [
      "This is a link ",
      [ :a, "http://www.wikicreole.org/", { :href => "http://www.wikicreole.org/" } ],
      " and another one ",
      [ :a, "http://rubygems.org", { :href => "http://rubygems.org" } ],
      "."
    ] ]]
    
    assert_equal struct,
      Markup.new("This is a link [[http://www.wikicreole.org/]] and another one [[http://rubygems.org]].").parse
  end

  test "should parse image" do
    assert_equal [[:p, [[:img, nil, { :src => "/images/alml.png", :alt => nil }]]]],
      Markup.new("{{/images/alml.png}}").parse
  end

  test "should parse image with alt" do
    assert_equal [[:p, [[:img, nil, { :src => "/images/alml.png", :alt => "This is an image" }]]]],
      Markup.new("{{/images/alml.png|This is an image}}").parse
  end
end
