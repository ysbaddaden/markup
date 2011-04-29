require 'test_helper'

class HtmlTest < ActiveSupport::TestCase
  test "formatter" do
    html = "<h1>Heading 1</h1>" +
      "<p>The very first paragraph.</p>" +
      "<h2>Heading 2</h2>" +
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
    html = "<h1>Heading 1</h1>
<p>The very first paragraph.</p>
<h2>Heading 2</h2>
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
end
