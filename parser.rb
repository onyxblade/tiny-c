require './tokenizer'

code = File.open('test/factorial.c').read
tokens = Tokenizer.new.tokenize(code)

class Parser
  def parse(tokens)
    @tokens = tokens
    analyze
  end

  def analyze
    case
    when variable_definition?

    when function_definition?

    end
  end

  def variable_definition?
    @tokens[0][0] == :type && @tokens[1][0] == :iden && @tokens[2][0] != :left_paren
  end

  def function_definition?
    @tokens[0][0] == :type && @tokens[1][0] == :iden && @tokens[2][0] == :left_paren
  end
end

Parser.new.parse(tokens)