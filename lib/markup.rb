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
        [ :blockquote, str.gsub(QUOTE_CLEAN, '').gsub(/\n/, ' ').strip ]
      
      when LIST_RE
        [ $1 == "#" ? :ol : :ul, parse_list_items(str) ]
      
      else
        if options[:p] == false
          str.strip
        else
          [ :p, str.gsub(/\n/, ' ').strip ]
        end
      end
    end.compact
  end

  def to_html
    str = _to_html(parse)
    str.respond_to?(:html_safe) ? str.html_safe : str
  end

  protected
    def _to_html(struct)
      struct.collect do |tag, struct|
        if tag.is_a?(String)
          tag
        else
          content = struct.is_a?(Array) ? _to_html(struct) : struct
          "<#{tag}>#{content}</#{tag}>"
        end
      end.join
    end

    def parse_blocks(text)
      text.sub(/\A(?:\s*?\n)*/m, "").split(/\n\n/)
    end

    def parse_list_items(text)
      text.split(LIST_SPLIT).collect do |str|
        next if str.blank?
        
        str.gsub!(/^[ ]{2}/, "")
        item, str = $1, $2 if str =~ NESTED_BLOCK
        
        struct = parse(str, :p => !!(str =~ /\n\n/)) unless str.blank?
        struct.unshift(item) if item
        
        [ :li, struct.size > 1 ? struct : struct.first ]
      end.compact
    end
end
