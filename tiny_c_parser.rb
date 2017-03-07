require './parser'
require './tokenizer'

class TinyCParser < Parser

  rule :function_definition do
    match :type, :iden, :arguments, :block do
      [:function_definition, @type, @iden, @arguments, @block]
    end
  end

  rule :arguments do
    match '(', :type, :iden, :arguments_tail do
      @arguments_tail.unshift [@type, @iden]
    end
  end

  rule :arguments_tail do
    match ')' do
      []
    end

    match ',', :type, :iden, :arguments_tail do
      @arguments_tail.unshift [@type, @iden]
    end
  end

  rule :type do
    match :iden do
      [:type, @iden[1]]
    end
  end

  rule :block do
    match '{', :statement, :block_tail do
      @block_tail.unshift @statement
    end
  end

  rule :block_tail do
    match '}' do
      []
    end

    match :statement, :block_tail do
      @block_tail.unshift @statement
    end
  end

  rule :statement do
    match :return, :expression, ';' do
      [:return, @expression]
    end

    match :if, '(', :expression, ')', :block, :else, :else_block do
      [:if, @expression, @block, @else_block]
    end

    match :if, '(', :expression, ')', :block do
      [:if, @expression, @block]
    end

    match :expression, ';' do
      @expression
    end
  end

  rule :else_block do
    match :block do
      @block
    end
  end

  rule :expression do
    match :relational_expression do
      @relational_expression
    end

    match :assignment do
      @assignment
    end
  end

  rule :factor do
    match '(', :expression, ')' do
      @expression
    end

    match :number do
      @number[1]
    end

    match :int do
      [:int, @int[1].to_i]
    end

    match :function_call do
      @function_call
    end

    match :iden do
      [:iden, @iden[1]]
    end

  end

  rule :function_call do
    match :iden, '(', :actual_params, ')' do
      [:call, @iden, @actual_params]
    end
  end

  rule :actual_params do
    match :expression, :actual_params_tail do
      @actual_params_tail.unshift @expression
    end
  end

  rule :actual_params_tail do
    match ',', :expression, :actual_params_tail do
      @actual_params_tail.unshift @expression
    end

    match :empty do
      []
    end
  end

  binary_operation :relational_expression, :relational_operator, :additive_expression
  binary_operation :additive_expression, :additive_operator, :multiplicative_expression
  binary_operation :multiplicative_expression, :multiplicative_operator, :factor

end

code = File.open('test/factorial.c').read
tokens = Tokenizer.new.tokenize(code)
p TinyCParser.new(:function_definition).parse(tokens)
