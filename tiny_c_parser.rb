require './parser'

class TinyCParser < Parser

  rule :factor do
    match '(', :expr, ')' do
      @expr
    end

    match :number do
      @number[1]
    end
  end

  binary_operation :expr, :additive_operator, :term
  binary_operation :term, :multiplicative_operator, :factor

end

tokens = [[:number, 1], [:additive_operator, "+"], [:number, 2], [:multiplicative_operator, "*"], [:number, 3], [:multiplicative_operator, "/"], ["("], [:number, 4], [:additive_operator, "-"], [:number, 2], [")"]]
p TinyCParser.new(:expr).parse(tokens)
