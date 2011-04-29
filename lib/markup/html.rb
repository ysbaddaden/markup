class Markup
  module HTML
    def to_html(options = {})
      str = _to_html(parse, options).strip
      str.respond_to?(:html_safe) ? str.html_safe : str
    end

    protected
      def _to_html(struct, options = {})
        deep = options[:deep] || 0
        
        html = struct.collect do |tag, struct|
          if tag.is_a?(String)
            tag
          else
            content = struct.is_a?(Array) ? _to_html(struct, options.merge(:deep => deep + 1)) : struct
            "<#{tag}>#{content}</#{tag}>"
          end
        end
        
        if options[:indent]
          indent  = "  "
          html.insert(0, "").join("\n#{indent * deep}") + "\n" + (indent * [0, deep - 1].max)
        else
          html.join
        end
      end
  end
end
