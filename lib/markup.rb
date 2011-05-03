# encoding: utf-8
require 'active_support/core_ext/class'
require 'markup/html'

# TODO: parse tables |= head 1 |=head2\n|row 1 cell 1|row 1 cell 2\n
class Markup
  include HTML

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

  cattr_accessor :inlines_re
  self.inlines_re = /(?:(^|[^\w])(\*\*|\/\/|__|~~|`|\^\^|,,)(.+?)\2([^\w]|$)|(\[\[)(.+?)\]\]|(\{\{)(.+?)\}\})/

  attr_accessor :input_string, :toc

  def initialize(input_string)
    self.input_string = input_string
    self.toc = []
  end

  def parse(options = {})
    parse_blocks(input_string, options)
  end

  protected
    # Parses text for block elements to the internal AST.
    def parse_blocks(text, options = {})
      split(text).collect do |str|
        next if str.blank?
        
        case str
        when self.class.heading_re
          tag = "h#{$1.size}".to_sym
          id  = $2.parameterize
          self.toc << [ tag, $2, id ]
          [ tag, $2, { :id => id } ]
        
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

    # Splits a text for block elements.
    def split(text)
      text.gsub(/\r\n/, "\n").sub(/\A(?:\s*?\n)*/m, "").split(/\n\n/)
    end

    # Parses a list block. Will parse nested blocks.
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

    # Parses a blockquote block. Will parse nested blocks.
    def parse_blockquote(text)
      text.gsub!(self.class.quote_clean, '')
      
      unless text.blank?
        struct = parse_blocks(text, :p => !!(text =~ /\n\n/))
        struct.size > 1 ? struct : struct.first
      end
    end

    # Parses a block of text for inline elements (bold, italic, links, etc.)
    def parse_inlines(str)
      parts = str.split(self.class.inlines_re)
      spans = []
      
      i = 0
      until parts[i].nil?
        case parts[i]
        when '**'
          spans << [ :b,   parse_inlines(parts[i+=1]) ]
        when '//'
          spans << [ :i,   parse_inlines(parts[i+=1]) ]
        when '__'
          spans << [ :u,   parse_inlines(parts[i+=1]) ]
        when '~~'
          spans << [ :s,   parse_inlines(parts[i+=1]) ]
        when '^^'
          spans << [ :sup, parse_inlines(parts[i+=1]) ]
        when ',,'
          spans << [ :sub, parse_inlines(parts[i+=1]) ]
        when '`'
          spans << [ :code, parts[i+=1] ]
        when '[['
          url, contents = parse_link(parts[i+=1])
          spans << [ :a, contents, { :href => url } ]
        when '{{'
          url, alt = parse_image(parts[i+=1])
          spans << [ :img, nil, { :src => url, :alt => alt } ]
        else
          unless parts[i].empty?
            part = parts[i].blank? ? " " : smart_punctuation(parts[i])
            
            if spans.last.is_a?(String)
              spans[spans.size - 1] += part
            else
              spans << part
            end
          end
        end
        
        i += 1
      end
      
      (spans.size == 1 && spans[0].is_a?(String)) ? spans.first : spans
    end

    def parse_link(text)
      url, contents = text.split('|', 2)
      contents = contents.nil? ? url : smart_punctuation(contents)
      [url, contents]
    end

    def parse_image(text)
      url, alt = text.split('|', 2)
      contents = contents.nil? ? url : smart_punctuation(alt)
      [url, alt]
    end

    def smart_punctuation(text)
      text.
        gsub(/\.\.\./, '…').                       # ellipsis
        gsub(/ - /, ' – ').gsub(/--/, '—').        # en & em dashes
        gsub(/(\S)'(\S)/, '\1’\2').                # apostrophes
        gsub(/'(\S)/, '‘\1').gsub(/(\S)'/, '\1’'). # single quotation marks
        gsub(/"(\S)/, '“\1').gsub(/(\S)"/, '\1”'). # double quotation marks
        gsub(/\s:/, ' :').                         # french nbsp (U+00A0)
        gsub(/\s+(;|\?|\!|»)/, ' \1').             # french thin nbsp (U+202F)
        gsub(/«\s+/, '\1 ').                       # french quotation thin nbsp (U+202F)
        gsub(/(\s—\s+)(.+?)(\s+—\s)/, ' — \2 — ')  # french em dashes (with thin nbsp)
    end
end
