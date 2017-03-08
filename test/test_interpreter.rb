require 'minitest/autorun'
require '../tokenizer'
require '../parser'
require '../interpreter'

class TestInterpreter < Minitest::Test
  def test_factorial
    code = File.open('factorial.c').read
    tokens = Tokenizer.new.tokenize(code)
    sexp = Parser.new.parse(tokens)
    result = Interpreter.new.run(sexp)
    assert_equal 120, result
  end

  def test_loop
    code = File.open('loop.c').read
    tokens = Tokenizer.new.tokenize(code)
    sexp = Parser.new.parse(tokens)
    result = Interpreter.new.run(sexp)
    assert_equal 100, result
  end
end