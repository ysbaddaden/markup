require 'test_helper'

class MarkupTest < ActiveSupport::TestCase
  test "should clear starting blank lines" do
    assert_equal [[:h1, "abcd"]], Markup.new("\n  \n\n= abcd\n").parse
  end

  test "should skip blank blocks" do
    assert_equal [], Markup.new("\n  \n\n\n\n  \n \n\n").parse
  end

  test "should parse paragraph" do
    assert_equal [[:p, "abcd"]], Markup.new("abcd").parse
  end

  test "should parse multi-line paragraph" do
    assert_equal [[:p, "lorem ipsum dolor sit amet"]],
      Markup.new("lorem ipsum\ndolor sit\namet").parse
  end

  test "should parse paragraphs" do
    assert_equal [[:p, "lorem ipsum dolor sit amet"], [:p, "Finibus Bonorum et Maloru"]],
      Markup.new("lorem ipsum\ndolor sit amet\n\nFinibus Bonorum\net Maloru").parse
  end

  test "should parse blockquote" do
    assert_equal [[:blockquote, "lorem ipsum dolor sit amet"]],
      Markup.new("> lorem ipsum\n> dolor sit amet").parse
  end

  test "should parse heading" do
    assert_equal [[:h1, "abcd"]], Markup.new("= abcd").parse
    assert_equal [[:h2, "abcd"]], Markup.new("== abcd").parse
    assert_equal [[:h3, "abcd"]], Markup.new("=== abcd").parse
    assert_equal [[:h4, "abcd"]], Markup.new("==== abcd").parse
    assert_equal [[:h5, "abcd"]], Markup.new("===== abcd").parse
    assert_equal [[:h6, "abcd"]], Markup.new("====== abcd").parse
  end

  test "should parse preformated text" do
    assert_equal [[:pre, "  lorem ipsum\n dolor sit\namet"]],
      Markup.new("      lorem ipsum\n     dolor sit\n    amet").parse
  end

  test "should parse unordered list" do
    assert_equal [[:ul, [[:li, "item 1"], [:li, "item 2"], [:li, "item 3"]]]],
      Markup.new("- item 1\n- item 2\n- item 3").parse
    
    assert_equal [[:ul, [[:li, "item 1"], [:li, "item 2"], [:li, "item 3"], [:li, "item 4"]]]],
      Markup.new("* item 1\n* item 2\n* item 3\n* item 4").parse
  end

  test "should parse ordered list" do
    assert_equal [[:ol, [[:li, "item 1"], [:li, "item 2"], [:li, "item 3"]]]],
      Markup.new("# item 1\n# item 2\n# item 3").parse
  end

  test "should parse nested list" do
    text =<<-EOV
- item a:
  - sub item a1,
  - sub item a2;
- item b:
  - sub item b1;
- item c;
- item d:
  - sub item d1,
  - sub item d2,
  - sub item d3;
EOV
    struct = [[ :ul, [
      [:li, ["item a:", [:ul, [[:li, "sub item a1,"], [:li, "sub item a2;"]]]]],
      [:li, ["item b:", [:ul, [[:li, "sub item b1;"]]]]],
      [:li, "item c;"],
      [:li, ["item d:", [:ul, [[:li, "sub item d1,"], [:li, "sub item d2,"], [:li, "sub item d3;"]]]]],
    ]]]
    assert_equal struct, Markup.new(text).parse
  end

  test "should parse" do
    text =<<-EOV
= The standard Lorem Ipsum passage, used since the 1500s

Lorem ipsum dolor sit amet, consectetur adipisicing elit,
sed do eiusmod tempor incididunt ut labore et dolore magna
aliqua.

    Ut enim ad minim veniam, quis nostrud exercitation ullamco
    laboris nisi ut aliquip ex ea commodo consequat.
    
    Duis aute irure dolor in reprehenderit in voluptate velit
    esse cillum dolore eu fugiat nulla pariatur.

Excepteur sint occaecat cupidatat non proident, sunt in
culpa qui officia deserunt mollit anim id est laborum.
EOV
    blocks = [
      [ :h1, "The standard Lorem Ipsum passage, used since the 1500s" ],
      [ :p, "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua." ],
      [ :pre, "Ut enim ad minim veniam, quis nostrud exercitation ullamco
laboris nisi ut aliquip ex ea commodo consequat.

Duis aute irure dolor in reprehenderit in voluptate velit
esse cillum dolore eu fugiat nulla pariatur." ],
      [ :p, "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." ]
    ] 
    assert_equal blocks, Markup.new(text).parse
  end

  test "should parse text with nested lists" do
    text =<<-EOV

= Heading 1

The very first
paragraph.

== Heading 2

# item 1
  - A first paragraph
    inside a nested list.
    
    A second paragraph
    inside a nested list.
  
# item 2
  - 2.a
  - Another paragraph
    inside a nested list.
    
    Yet another paragraph.

EOV
  assert_equal [
    [ :h1, "Heading 1" ],
    [ :p,  "The very first paragraph." ],
    [ :h2, "Heading 2" ],
    [ :ol, [
      [ :li, [
        "item 1",
        [ :ul, [
          [ :li, [
            [ :p, "A first paragraph inside a nested list." ],
            [ :p, "A second paragraph inside a nested list." ]
          ]]
        ]]
      ]],
      [ :li, [
        "item 2",
        [ :ul, [
          [ :li, "2.a" ],
          [ :li, [
            [ :p, "Another paragraph inside a nested list." ],
            [ :p, "Yet another paragraph." ]
          ]]
        ]]
      ]]
    ]]
  ], Markup.new(text).parse
  end
end
