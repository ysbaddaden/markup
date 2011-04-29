# encoding: utf-8
require 'active_support/core_ext/class'

# TODO: parse inline markup: links and images.
# IMPROVE: generate table of content from headings.
class Markup
  attr_accessor :input_string

  cattr_accessor :heading_re
  self.heading_re = /\A(=+)\s*(.+?)\s*\Z/

  cattr_accessor :pre_re, :pre_clean
  self.pre_re    = /\A[ ]{4}/
  self.pre_clean = /^[ ]{4}/

  cattr_accessor :quote_re, :quote_clean
  self.quote_re    = /\A> /
  self.quote_clean = /^> /

  cattr_accessor :list_re, :list_split, :list_clean, :nested_block
  self.list_re      = /^([#*-]) /
  self.list_split   = /^[#*-] /
  self.list_clean   = /^[ ]{2}/
  self.nested_block = /\A(.*?)\n([-*#=>] .*)\Z/m

  cattr_accessor :inlines, :inlines_re
#  self.inlines = { :b => "**", :i => "//", :u => "__", :s => "~~", :code => "`" }
  self.inlines = { "**" => :b, "//" => :i, "__" => :u, "~~" => :s, "`" => :code }

  def self.inlines_re
    if @inlines_re.nil?
      str = inlines.keys.map { |s| Regexp.escape(s) }.join("|")
      @inlines_re = Regexp.new("(#{str})([^\\s].+?[^\\s])\\1")
    end
    
    @inlines_re
  end

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
        when self.class.heading_re
          [ "h#{$1.size}".to_sym, $2 ]
        
        when self.class.pre_re
          [ :pre, str.gsub(self.class.pre_clean, '') ]
        
        when self.class.quote_re
          [ :blockquote, parse_blockquote(str) ]
        
        when self.class.list_re
          [ $1 == "#" ? :ol : :ul, parse_list(str) ]
        
        else
          str = parse_inlines(str.gsub(/\n/, ' ').strip)
          options[:p] == false ? str : [ :p, str ]
        end
      end.compact
    end

    def parse_list(text)
      text.split(self.class.list_split).collect do |str|
        next if str.blank?
        
        str.gsub!(self.class.list_clean, "")
        item, str = $1, $2 if str =~ self.class.nested_block
        
        struct = parse_blocks(str, :p => !!(str =~ /\n\n/)) unless str.blank?
        struct.unshift(parse_inlines(item)) if item
        
        [ :li, struct.size > 1 ? struct : struct.first ]
      end.compact
    end

    def parse_blockquote(text)
      text.gsub!(self.class.quote_clean, '')
      
      unless text.blank?
        struct = parse_blocks(text, :p => !!(text =~ /\n\n/))
        struct.size > 1 ? struct : struct.first
      end
    end

    def parse_inlines(str)
      parts = str.split(self.class.inlines_re)
      spans = []
      
      i = 0
      until parts[i].nil?
        if self.class.inlines.has_key?(parts[i])
          tag = self.class.inlines[parts[i]]
          if tag == :code
            spans <<  [ tag, parts[i += 1] ]
          else
            spans <<  [ tag, parse_inlines(parts[i += 1]) ]
          end
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
