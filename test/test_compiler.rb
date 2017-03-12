require 'minitest/autorun'
require '../tokenizer'
require '../parser'
require '../compiler'

class TestCompiler < Minitest::Test

  def test_minimal
    code = File.open('minimal.c').read
    tokens = Tokenizer.new.tokenize(code)
    sexp = Parser.new.parse(tokens)
    result = Compiler.new.compile(sexp)
    puts result
    File.open('temp.s', 'w'){|f| f.write result}
    `gcc -o temp temp.s`
    #puts result
  end
end