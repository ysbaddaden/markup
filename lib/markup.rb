require 'pp'

class Markup
  attr_accessor :input_string

  NESTED_BLOCK = /\A(.*?)\n([-*#=>] .*)\Z/m

  HEADING_RE   = /\A(=+)\s*(.+?)\s*\Z/

  PRE_RE       = /\A[ ]{4}/
  PRE_CLEAN    = /^[ ]{4}/

  QUOTE_RE     = /\A> /
  QUOTE_CLEAN  = /^> /

  LIST_RE      = /^([#*-]) /
  LIST_SPLIT   = /^[#*-] /

  def initialize(input_string)
    self.input_string = input_string
  end

  # Parses a text for block elements like headings and paragraphs.
  def parse(text = input_string, options = {})
    parse_blocks(text).collect do |str|
      next if str.blank?
      
      if str =~ HEADING_RE
        [ "h#{$1.size}".to_sym, $2 ]
      
      elsif str =~ PRE_RE
        [ :pre, str.gsub(PRE_CLEAN, '') ]
      
      elsif str =~ QUOTE_RE
        [ :blockquote, str.gsub(QUOTE_CLEAN, '').gsub(/\n/, ' ').strip ]
      
      elsif str =~ LIST_RE
        [ $1 == "#" ? :ol : :ul, parse_list_items(str) ]
      
      elsif options[:p] != false
        [ :p, str.gsub(/\n/, ' ').strip ]
      
      else
        str.strip
      end
    end.compact
  end

  def parse_blocks(text)
    text.sub(/\A(?:\s*?\n)*/m, "").split(/\n\n/)
  end

  def to_html
    str = _to_html
    str.respond_to?(:html_safe) ? str.html_safe : str
  end

  protected
    def _to_html
      # ...
    end

    def parse_list_items(text)
      text.split(LIST_SPLIT).collect do |str|
        unless str.blank?
          str.gsub!(/^[ ]{2}/, "")
          item, str = $1, $2 if str =~ NESTED_BLOCK
          
          struct = parse(str, :p => !!(str =~ /\n\n/)) unless str.blank?
          struct.unshift(item) if item
          
          [ :li, struct.size > 1 ? struct : struct.first ]
        end 
      end.compact
    end
end
