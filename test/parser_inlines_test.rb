require 'test_helper'

class ParserInlinesTest < ActiveSupport::TestCase
  test "should parse bold" do
    assert_equal [[:p, [ "lorem ipsum", [:b, "dolor sit"], "amet" ]]],
      Markup.new("lorem ipsum **dolor sit** amet").parse
  end

  test "should parse italic" do
    assert_equal [[:p, [ "lorem", [:i, "ipsum"], "dolor sit amet" ]]],
      Markup.new("lorem //ipsum// dolor sit amet").parse
  end

  test "should parse bold within italic" do
    assert_equal [[:p, [ "lorem", [:i, ["ipsum", [:b, "dolor sit"]]], "amet" ]]],
      Markup.new("lorem //ipsum **dolor sit**// amet").parse
  end

  test "should parse italic within bold" do
    assert_equal [[:p, [[:b, [[:i, "lorem ipsum"], "dolor"]], "sit amet"] ]],
      Markup.new("**//lorem ipsum// dolor** sit amet").parse
  end

  test "should parse bold and italic within list items" do
    assert_equal [[ :ul, [ [:li, [[:b, "item"], "1"]], [:li, [[:i, "item"], "2"]] ] ]],
      Markup.new("- **item** 1\n- //item// 2").parse
  end
end
