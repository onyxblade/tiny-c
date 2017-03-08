
class ParserUtil

  class RuleDefineEvalEnv < Object
    def match *tokens, &block
      @matches ||= {}
      @matches[tokens] = block
      @matches
    end
  end

  class MatchedEvalEnv < Object
    def initialize(tokens, matched)
      tokens.zip(matched).each do |name, value|
        next unless name.is_a? Symbol
        instance_variable_set("@#{name}", value)
      end
      @matched = matched
    end
  end

  class << self
    attr_reader :rules

    def rule name, **options, &block
      @rules ||= {}
      @rules[name] = RuleDefineEvalEnv.new.instance_eval(&block)
    end

    def binary_operation term_name, operator_name, factor_name, &block
      tail_name = "#{term_name}_tail".to_sym
      rule term_name do
        match factor_name, tail_name do
          instance_variable_get("@#{tail_name}").call(instance_variable_get("@#{factor_name}"))
        end
      end

      rule tail_name do |params|
        match operator_name, factor_name, tail_name do
          if block_given?
            ->(left){
              operator = instance_variable_get("@#{operator_name}")[1]
              right = instance_variable_get("@#{factor_name}")
              instance_variable_get("@#{tail_name}").call(block.call(operator, left, right))
            }
          else
            ->(n){ instance_variable_get("@#{tail_name}").call [:call, instance_variable_get("@#{operator_name}")[1], [n, instance_variable_get("@#{factor_name}")]] }
          end
        end

        match :empty do
          ->(n){ n }
        end
      end
    end

  end

  def rules
    self.class.rules
  end

  def parse(tokens)
    @tokens = tokens
    @index = 0
    match_rule(@start_rule).tap do
      puts "Warning: not consumming all tokens, may have syntax error" if @index < @tokens.size
    end
  end

  def initialize start_rule = :program
    @start_rule = start_rule
  end

  def match_rule rule_name
    result = false
    rules[rule_name].each do |tokens, block|
      return result if result = match_rule_line(*tokens, block)
    end
    result
  end

  def match_rule_line *tokens, block
    old_index = @index
    line_result = tokens.map do |token|
      if rules[token]
        rule_result = match_rule(token)
        if rule_result
          rule_result
        else
          return false
        end
      elsif token == :empty
        nil
      else
        if current_token == token
          @index += 1
          @tokens[@index-1]
        else
          @index = old_index
          return false
        end
      end
    end
    MatchedEvalEnv.new(tokens, line_result).instance_eval(&block)
  end

  def current_token
    @tokens[@index][0]
  rescue
    :empty
  end

end