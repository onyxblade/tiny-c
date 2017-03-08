require 'minitest/autorun'
require '../tokenizer'
require '../parser'
require '../compiler'

class TestCompiler < Minitest::Test
  def test_minimal
    code = File.open('loop.c').read
    tokens = Tokenizer.new.tokenize(code)
    sexp = Parser.new.parse(tokens)
    result = Compiler.new.compile(sexp)
  end
end