require 'strscan'

class Tokenizer
  def tokenize(str)
    ss = StringScanner.new(str)
    tokens = []

    until ss.empty?
      case
      when ss.scan(/\s/)
        # do nothing
      #when ss.scan(/int|float|unsigned int/)
      #  tokens << [:type, ss.matched]
      when ss.scan(/\d+/)
        tokens << [:int, ss.matched]
      when ss.scan(/\d+\.\d+/)
        tokens << [:float, ss.matched]
      when ss.scan(/return/)
        tokens << [:return]
      when ss.scan(/if/)
        tokens << [:if]
      when ss.scan(/else/)
        tokens << [:else]
      when ss.scan(/\w+/)
        tokens << [:iden, ss.matched]
      when ss.scan(/[\(\)\{\},;]/)
        tokens << [ss.matched]
      when ss.scan(/[\+\-]/)
        tokens << [:additive_operator, ss.matched]
      when ss.scan(/[\*\/]/)
        tokens << [:multiplicative_operator, ss.matched]
      when ss.scan(/(==)|(!=)|(<=)|(>=)|>|</)
        tokens << [:relational_operator, ss.matched]
      when ss.scan(/=/)
        tokens << [:assign]
      else
        p ss
        raise "unknown token"
      end
    end
    tokens
  end
end