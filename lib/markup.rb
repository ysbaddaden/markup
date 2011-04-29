# encoding: utf-8

# TODO: parse inline markup: links and images.
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

  def parse(options = {})
    parse_blocks(input_string, options)
  end

  def to_html(options = {})
    str = _to_html(parse, options).strip
    str.respond_to?(:html_safe) ? str.html_safe : str
  end

  protected
    # Splits a text for block elements.
    def split(text)
      text.sub(/\A(?:\s*?\n)*/m, "").split(/\n\n/)
    end

    # Parses text for block elements to the internal AST.
    def parse_blocks(text, options = {})
      split(text).collect do |str|
        next if str.blank?
        
        case str
        when HEADING_RE
          [ "h#{$1.size}".to_sym, $2 ]
        
        when PRE_RE
          [ :pre, str.gsub(PRE_CLEAN, '') ]
        
        when QUOTE_RE
          [ :blockquote, parse_blockquote(str) ]
        
        when LIST_RE
          [ $1 == "#" ? :ol : :ul, parse_list(str) ]
        
        else
          str = parse_inlines(str.gsub(/\n/, ' ').strip)
          options[:p] == false ? str : [ :p, str ]
        end
      end.compact
    end

    def parse_list(text)
      text.split(LIST_SPLIT).collect do |str|
        next if str.blank?
        
        str.gsub!(LIST_CLEAN, "")
        item, str = $1, $2 if str =~ NESTED_BLOCK
        
        struct = parse_blocks(str, :p => !!(str =~ /\n\n/)) unless str.blank?
        struct.unshift(parse_inlines(item)) if item
        
        [ :li, struct.size > 1 ? struct : struct.first ]
      end.compact
    end

    def parse_blockquote(text)
      text.gsub!(QUOTE_CLEAN, '')
      
      unless text.blank?
        struct = parse_blocks(text, :p => !!(text =~ /\n\n/))
        struct.size > 1 ? struct : struct.first
      end
    end

    def parse_inlines(str)
#      parts = str.split(/\s*(\*\*|\/\/|__|~~|`)([^\s].+?[^\s])\1\s*/)
      parts = str.split(/(\*\*|\/\/|__|~~|`)([^\s].+?[^\s])\1/)
      spans = []
      
      i = 0
      until parts[i].nil?
        case parts[i]
        when '**'
          spans << [ :b, parse_inlines(parts[i += 1]) ]
        when '//'
          spans << [ :i, parse_inlines(parts[i += 1]) ]
        when '__'
          spans << [ :u, parse_inlines(parts[i += 1]) ]
        when '~~'
          spans << [ :s, parse_inlines(parts[i += 1]) ]
        when '`'
          spans << [ :code, parts[i += 1] ]
        else
          spans << self.class.smart_punctuation(parts[i]) unless parts[i].blank?
        end
        
        i += 1
      end
      
      spans.compact
      spans.size > 1 ? spans : spans.first
    end

    def self.smart_punctuation(text)
      text.
        gsub(/\.\.\./, '…').                       # ellipsis
        gsub(/ - /, ' – ').gsub(/--/, '—').        # en & em dashes
        gsub(/(\S)'(\S)/, '\1’\2').                # apostrophes
        gsub(/'(\S)/, '‘\1').gsub(/(\S)'/, '\1’'). # single quotation marks
        gsub(/"(\S)/, '“\1').gsub(/(\S)"/, '\1”'). # double quotation marks
        gsub(/\s:/, ' :').                         # french nbsp (U+00A0)
        gsub(/\s+(;|\?|\!|»)/, ' \1').             # french fine nbsp (U+202F)
        gsub(/«\s+/, '\1 ').                       # french quotation fine nbsp (U+202F)
        gsub(/(\s—\s+)(.+?)(\s+—\s)/, ' — \2 — ')  # french em dashes (with fine nbsp)
    end

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
