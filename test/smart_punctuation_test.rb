# encoding: utf-8

require 'test_helper'

class SmartPunctuationTest < ActiveSupport::TestCase
  test "should parse single quotes" do
    assert_equal [[:p, "lorem ‘ipsum’ dolor sit amet"]], Markup.new("lorem 'ipsum' dolor sit amet").parse
    assert_equal [[:p, "it’s a good day"]], Markup.new("it's a good day").parse
  end

  test "should parse double quotes" do
    assert_equal [[:p, "lorem “ipsum dolor” sit amet"]], Markup.new('lorem "ipsum dolor" sit amet').parse
  end

  test "should parse en dashes" do
    assert_equal [[:p, "a + b = c – d"]], Markup.new('a + b = c - d').parse
  end

  test "should parse em dashes" do
    assert_equal [[:p, "lorem ipsum —dolor sit— amet"]], Markup.new('lorem ipsum --dolor sit-- amet').parse
  end

  test "should parse ellipsis" do
    assert_equal [[:p, "I never drink … wine"]], Markup.new("I never drink ... wine").parse
  end

  test "should replace french non breaking spaces" do
    assert_equal [[:p, "lorem ipsum — dolor sit — amet"]],
      Markup.new('lorem ipsum -- dolor sit -- amet').parse
    
    assert_equal [[:p, "Langues :", ], [ :ul, [[:li, "français ;"], [:li, "anglais."]] ]],
      Markup.new("Langues : \n\n- français ;\n- anglais.").parse
  end

#  test "should not parse" do
#    assert_equal [[:p, "lorem 'ipsum' dolor sit amet"]], Markup.new("lorem \'ipsum\' dolor sit amet").parse
#    assert_equal [[:p, 'lorem "ipsum dolor" sit amet']], Markup.new('lorem \"ipsum dolor\" sit amet').parse
#    assert_equal [[:p, "a + b = c - d"]], Markup.new('a + b = c \- d').parse
#  end
end
