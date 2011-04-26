# TODO: parse inline markup: bold, italic, underline, links and images.
# IMPROVE: generate table of content from headings.
class Markup
  attr_accessor :input_string

  HEADING_RE   = /\A(=+)\s*(.+?)\s*\Z/

  PRE_RE       = /\A[ ]{4}/
  PRE_CLEAN    = /^[ ]{4}/

  QUOTE_RE     = /\A> /
  QUOTE_CLEAN  = /^> /

  LIST_RE      = /^([#*-]) /
  LIST_SPLIT   = /^[#*-] /
  LIST_CLEAN   = /^[ ]{2}/
  NESTED_BLOCK = /\A(.*?)\n([-*#=>] .*)\Z/m

  def initialize(input_string)
    self.input_string = input_string
  end

  # Parses a text for block elements like headings and paragraphs.
  def parse(text = input_string, options = {})
    parse_blocks(text).collect do |str|
      next if str.blank?
      
      case str
      when HEADING_RE
        [ "h#{$1.size}".to_sym, $2 ]
      
      when PRE_RE
        [ :pre, str.gsub(PRE_CLEAN, '') ]
      
      when QUOTE_RE
        [ :blockquote, parse_blockquote(str) ]
      
      when LIST_RE
        [ $1 == "#" ? :ol : :ul, parse_list_items(str) ]
      
      else
        str = str.gsub(/\n/, ' ').strip
        options[:p] == false ? str : [ :p, str ]
      end
    end.compact
  end

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

    def parse_blocks(text)
      text.sub(/\A(?:\s*?\n)*/m, "").split(/\n\n/)
    end

    def parse_list_items(text)
      text.split(LIST_SPLIT).collect do |str|
        next if str.blank?
        
        str.gsub!(LIST_CLEAN, "")
        item, str = $1, $2 if str =~ NESTED_BLOCK
        
        struct = parse(str, :p => !!(str =~ /\n\n/)) unless str.blank?
        struct.unshift(item) if item
        
        [ :li, struct.size > 1 ? struct : struct.first ]
      end.compact
    end

    def parse_blockquote(text)
      text.gsub!(QUOTE_CLEAN, '')
      
      unless text.blank?
        struct = parse(text, :p => !!(text =~ /\n\n/))
        struct.size > 1 ? struct : struct.first
      end
    end
end
