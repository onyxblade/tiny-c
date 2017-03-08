require_relative './parser_util'

class Parser < ParserUtil

  rule :program do
    match :eof do
      []
    end

    match :function_definition, :program do
      @program.unshift @function_definition
    end
  end

  rule :function_definition do
    match :type, :iden, :formal_params, :block do
      [:define_func, @type[1], @iden[1], @formal_params, @block]
    end
  end

  rule :formal_params do
    match '(', ')' do
      []
    end

    match ')' do
      []
    end

    match ',', :type, :iden, :formal_params do
      @formal_params.unshift [@type[1], @iden[1]]
    end

    match '(', :type, :iden, :formal_params do
      @formal_params.unshift [@type[1], @iden[1]]
    end
  end

  rule :variable_definition do
    match :type, :iden, :assignment_operator, :expression do
      [:define_var, @type[1], @iden[1], @expression]
    end

    match :type, :iden do
      [:define_var, @type[1], @iden[1]]
    end
  end

  rule :type do
    match :iden do
      [:type, @iden[1]]
    end
  end

  rule :block do
    match '}' do
      []
    end

    match '{', :statement, :block do
      @block.unshift @statement
    end

    match :statement, :block do
      @block.unshift @statement
    end
  end

  rule :statement do
    match :return, :expression, ';' do
      [:return, @expression]
    end

    match :if, '(', :expression, ')', :block, :else, :block do
      [:if, @expression, @matched[4], @matched[6]]
    end

    match :if, '(', :expression, ')', :block do
      [:if, @expression, @block]
    end

    match :for, '(', :expression, ';', :expression, ';', :expression, ')', :block do
      [:for, @matched[2], @matched[4], @matched[6], @block]
    end

    match :while, '(', :expression, ')', :block do
      [:while, @expression, @block]
    end

    match :variable_definition, ';' do
      @variable_definition
    end

    match :expression, ';' do
      @expression
    end
  end

  rule :expression do
    match :assignment_expression do
      @assignment_expression
    end
  end

  rule :factor do
    match '(', :expression, ')' do
      @expression
    end

    match :int do
      [:int, @int[1].to_i]
    end

    match :function_call do
      @function_call
    end

    match :iden, :postfix_operator do
      case @postfix_operator[1]
      when '++'
        [:inc, @iden[1]]
      when '--'
        [:dec, @iden[1]]
      else
        raise "unknown postfix_operator #{@postfix_operator[1]}"
      end
    end

    match :iden do
      [:get, @iden[1]]
    end

  end

  rule :function_call do
    match :iden, :actual_params do
      [:call, @iden[1], @actual_params]
    end
  end

  rule :actual_params do
    match '(', ')' do
      []
    end

    match ')' do
      []
    end

    match '(', :expression, :actual_params do
      @actual_params.unshift @expression
    end

    match ',', :expression, :actual_params do
      @actual_params.unshift @expression
    end

  end

  binary_operation :assignment_expression, :assignment_operator, :relational_expression do |operator, left, right|
    if match = operator.match(/(.)=/)
      [:assign, left[1], [:call, match[1], [left, right]]]
    else
      [:assign, left[1], right]
    end
  end
  binary_operation :relational_expression, :relational_operator, :additive_expression
  binary_operation :additive_expression, :additive_operator, :multiplicative_expression
  binary_operation :multiplicative_expression, :multiplicative_operator, :factor

end