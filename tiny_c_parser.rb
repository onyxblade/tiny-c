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
    match '+', :term, :expr_tail do
      ->(n){ @expr_tail.call ['+', n, @term] }
    end

    match '-', :term, :expr_tail do
      ->(n){ @expr_tail.call ['-', n, @term] }
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

  rule :term_tail, empty: true do |params|
    match '*', :factor, :term_tail do
      ->(n){ @term_tail.call ['*', n, @factor] }
    end

    match '/', :factor, :term_tail do
      ->(n){ @term_tail.call ['/', n, @factor] }
    end

    match :empty do
      ->(n){ n }
    end
  end

end

tokens = [[:number, 1], ["+"], [:number, 2], ["*"], [:number, 3], ["/"], ["("], [:number, 4], ["-"], [:number, 2], [")"]]
p TinyCParser.new(:expr).parse(tokens)
