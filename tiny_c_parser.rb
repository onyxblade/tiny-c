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

  rule :expr do
    match :term, :expr_tail do
      @expr_tail.call(@term)
    end
  end

  rule :expr_tail do
    match :additive_operator, :term, :expr_tail do
      ->(n){ @expr_tail.call [@additive_operator[1], n, @term] }
    end

    match :empty do
      ->(n){ n }
    end
  end

  rule :term do
    match :factor, :term_tail do
      @term_tail.call(@factor)
    end
  end

  rule :term_tail do |params|
    match :multiplicative_operator, :factor, :term_tail do
      ->(n){ @term_tail.call [@multiplicative_operator[1], n, @factor] }
    end

    match :empty do
      ->(n){ n }
    end
  end

end

tokens = [[:number, 1], [:additive_operator, "+"], [:number, 2], [:multiplicative_operator, "*"], [:number, 3], [:multiplicative_operator, "/"], ["("], [:number, 4], [:additive_operator, "-"], [:number, 2], [")"]]
p TinyCParser.new(:expr).parse(tokens)
