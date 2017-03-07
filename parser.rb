
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