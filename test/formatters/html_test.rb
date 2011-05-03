require 'test_helper'

class HtmlTest < ActiveSupport::TestCase
  test "should escape html chars" do
    assert_equal "<p>bla bla &lt;bla&gt; &amp; again</p>", Markup.new("bla bla <bla> & again").to_html
    assert_equal "<ul><li>bla bla &lt;bla&gt; &amp; again</li></ul>", Markup.new("- bla bla <bla> & again").to_html
  end

  test "blocks" do
    html = "<h1 id=\"heading-1\">Heading 1</h1>" +
      "<p>The very first paragraph.</p>" +
      "<h2 id=\"heading-2\">Heading 2</h2>" +
      "<ol>" +
        "<li>" +
          "item 1" +
          "<ul>" +
            "<li>" +
              "<p>A first paragraph inside a nested list.</p>" +
              "<p>A second paragraph inside a nested list.</p>" +
            "</li>" +
          "</ul>" +
        "</li>" +
        "<li>" +
          "item 2" +
          "<ul>" +
            "<li>2.a</li>" +
            "<li>" +
              "<p>Another paragraph inside a nested list.</p>" +
              "<p>Yet another paragraph.</p>" +
            "</li>" +
          "</ul>" +
        "</li>" +
      "</ol>"
    assert_equal html, Markup.new(fixture(:blocks_in_nested_lists)).to_html
  end

  test "indentation" do
    html = "<h1 id=\"heading-1\">Heading 1</h1>
<p>The very first paragraph.</p>
<h2 id=\"heading-2\">Heading 2</h2>
<ol>
  <li>
    item 1
    <ul>
      <li>
        <p>A first paragraph inside a nested list.</p>
        <p>A second paragraph inside a nested list.</p>
      </li>
    </ul>
  </li>
  <li>
    item 2
    <ul>
      <li>2.a</li>
      <li>
        <p>Another paragraph inside a nested list.</p>
        <p>Yet another paragraph.</p>
      </li>
    </ul>
  </li>
</ol>"
    assert_equal html, Markup.new(fixture(:blocks_in_nested_lists)).to_html(:indent => true)
  end

  test "headings level" do
    assert_equal "<h3 id=\"heading-1\">Heading 1</h3><p>The very <b>first</b> paragraph.</p>",
      Markup.new("= Heading 1\n\nThe very **first** paragraph.").to_html(:headings => 3)
    
    assert_equal "<h1 id=\"heading-1\">Heading 1</h1><p>The very <b>first</b> paragraph.</p>",
      Markup.new("= Heading 1\n\nThe very **first** paragraph.").to_html(:headings => 1)
  end

  test "inlines" do
    assert_equal "<h1 id=\"heading-1\">Heading 1</h1><p>The very <b>first</b> paragraph.</p>",
      Markup.new("= Heading 1\n\nThe very **first** paragraph.").to_html
  end

#  test "indentation with inlines" do
#    assert_equal "<h1>Heading 1</h1>\n<p>The very <b>first</b> paragraph.</p>",
#      Markup.new("= Heading 1\n\nThe very **first** paragraph.").to_html(:indent => true)
#  end

  test "links" do
    assert_equal '<p>This is a link <a href="http://www.wikicreole.org/">http://www.wikicreole.org/</a> and another one <a href="http://rubygems.org">http://rubygems.org</a>.</p>',
      Markup.new("This is a link [[http://www.wikicreole.org/]] and another one [[http://rubygems.org]].").to_html
  end

  test "images" do
    assert_equal '<p><img alt="" src="/images/alml.png"/></p>',
      Markup.new("{{/images/alml.png}}").to_html
  end
end
