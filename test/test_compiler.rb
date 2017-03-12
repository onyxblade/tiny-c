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

  def test_relational_operation
    expressions = {
      "1<2" => 1,
      "1<1" => 0,
      "1>2" => 0,
      "2>=2" => 1,
    }
    expressions.each do |exp, res|
      code ="int main(){ return #{exp};}"
      tokens = Tokenizer.new.tokenize(code)
      sexp = Parser.new.parse(tokens)
      result = Compiler.new.compile(sexp)
      File.open('temp.s', 'w'){|f| f.write result}
      `gcc -o temp temp.s`
      `./temp`
      assert_equal res, $?.exitstatus
    end
  end

  def test_define_var
    code =<<~EOF
      int main(){
        int a = 2;
        int b = 3;
        a++;
        return a;
      }
    EOF
    tokens = Tokenizer.new.tokenize(code)
    sexp = Parser.new.parse(tokens)
    result = Compiler.new.compile(sexp)
    File.open('temp.s', 'w'){|f| f.write result}
    `gcc -o temp temp.s`
    `./temp`
    assert_equal 3, $?.exitstatus
  end

  def test_loop
    code = File.open('loop.c').read
    tokens = Tokenizer.new.tokenize(code)
    sexp = Parser.new.parse(tokens)
    result = Compiler.new.compile(sexp)
    File.open('temp.s', 'w'){|f| f.write result}
    `gcc -o temp temp.s`
    `./temp`
    assert_equal 100, $?.exitstatus
  end

end