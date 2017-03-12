require 'minitest/autorun'
require '../tokenizer'
require '../parser'
require '../compiler'
require 'pp'

class TestCompiler < Minitest::Test

  def test_minimal
    code = File.open('minimal.c').read
    tokens = Tokenizer.new.tokenize(code)
    sexp = Parser.new.parse(tokens)
    result = Compiler.new.compile(sexp)
    File.open('temp.s', 'w'){|f| f.write result}
    `gcc -o temp temp.s`
    `./temp`
    assert_equal 4, $?.exitstatus
  end

  def test_sum
    code = File.open('sum.c').read
    tokens = Tokenizer.new.tokenize(code)
    sexp = Parser.new.parse(tokens)
    result = Compiler.new.compile(sexp)
    File.open('temp.s', 'w'){|f| f.write result}
    `gcc -o temp temp.s`
    `./temp`
    assert_equal 5, $?.exitstatus
  end

  def test_factorial
    code = File.open('factorial.c').read
    tokens = Tokenizer.new.tokenize(code)
    sexp = Parser.new.parse(tokens)
    result = Compiler.new.compile(sexp)
    File.open('temp.s', 'w'){|f| f.write result}
    `gcc -o temp temp.s`
    `./temp`
    assert_equal 120, $?.exitstatus
  end
end