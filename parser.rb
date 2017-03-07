
class Parser

  class RuleDefineEvalEnv < Object
    attr_reader :matches

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

    def matched
      @matched
    end
  end

  class << self
    attr_reader :rules

    def rule name, **options, &block
      @rules ||= {}
      @rules[name] = RuleDefineEvalEnv.new.instance_eval(&block)
      #check_left_recursion(name, @rules[name])
    end

    def binary_operation term_name, operator, factor_name
      tail_name = "#{term_name}_tail".to_sym
      rule term_name do
        match factor_name, tail_name do
          instance_variable_get("@#{tail_name}").call(instance_variable_get("@#{factor_name}"))
        end
      end

      rule tail_name do |params|
        match operator_name, factor_name, tail_name do
          ->(n){ instance_variable_get("@#{tail_name}").call [instance_variable_get("@#{operator_name}")[1], n, instance_variable_get("@#{factor_name}")] }
        end

        match :empty do
          ->(n){ n }
        end
      end
    end

    def check_left_recursion(rule_name, rule)
      p rule.keys.any?{|x| x.first == rule_name}
    end
  end

  def rules
    self.class.rules
  end

  def parse(tokens)
    @tokens = tokens
    @index = 0
    match_rule @start_rule
  end

  def initialize start_rule = :program
    @start_rule = start_rule
  end

  def match_rule rule_name
    result = false
    rules[rule_name].each do |tokens, block|
      if result = match_rule_line(*tokens, block)
        return result
      end
    end
    raise "pattern exhausted, current_token: #{current_token}, matching: #{rule_name}"
  end

  def match_rule_line *tokens, block
    #p "matching #{tokens}"
    #p "current_token #{@tokens[@index]}"
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