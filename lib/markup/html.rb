require 'active_support/core_ext/hash'

class Markup
  module HTML
    # Formats text as HTML.
    # 
    # Available options:
    # 
    # - indent  - true to indent HTML tags.
    # - heading - level of first heading type (defaults to 1)
    # 
    # FIXME: indentation of inline elements isn't very sexy.
    def to_html(options = {})
      options[:headings] -= 1 if options[:headings]
      
      str = _to_html(parse, options).strip
      str.respond_to?(:html_safe) ? str.html_safe : str
    end

    protected
      def _to_html(struct, options = {})
        deep = options[:deep] || 0
        
        html = struct.collect do |tag, struct, attributes|
          if tag.is_a?(String)
            escape_html_chars(tag)
          else
            attributes = attributes.stringify_keys.sort.map { |k,v| " #{k}=\"#{v}\"" }.join unless attributes.nil?
            
            if struct.nil?
              "<#{tag}#{attributes}/>"
            else
              if struct.is_a?(Array)
                content = _to_html(struct, options.merge(:deep => deep + 1))
              else
                content = escape_html_chars(struct)
              end
              
              tag = "h#{$1.to_i + options[:headings]}" if options[:headings] && tag.to_s =~ /^h(\d)$/
              "<#{tag}#{attributes}>#{content}</#{tag}>"
            end
          end
        end
        
        if options[:indent]
          indent  = "  "
          html.insert(0, "").join("\n#{indent * deep}") + "\n" + (indent * [0, deep - 1].max)
        else
          html.join
        end
      end

      def escape_html_chars(text)
        text.gsub(/&/, '&amp;').gsub(/>/, '&gt;').gsub(/</, '&lt;')
      end
  end
end
