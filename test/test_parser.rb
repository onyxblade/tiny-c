require "minitest/autorun"
require '../tokenizer'
require '../parser'

class TestParser < Minitest::Test
  def test_factorial
    code = File.open('factorial.c').read
    tokens = Tokenizer.new.tokenize(code)
    sexp = Parser.new.parse(tokens)
    target =  [[:define_func,
                "int",
                "factorial",
                [["int", "n"]],
                [[:if,
                  [:call, "==", [[:get, "n"], [:int, 1]]],
                  [["return", [:int, 1]]],
                  [["return",
                    [:call,
                     "*",
                     [[:get, "n"],
                      [:call, "factorial", [[:call, "-", [[:get, "n"], [:int, 1]]]]]]]]]]]],
               [:define_func,
                "int",
                "main",
                [],
                [["return", [:call, "factorial", [[:int, 5]]]]]]]
    assert_equal target, sexp
  end

  def test_arithmetic
    code = "1 + 2 * 3 / (4 - 2)"
    tokens = Tokenizer.new.tokenize(code, false)
    sexp = Parser.new(:expression).parse(tokens)
    target =  [:call,
               "+",
               [[:int, 1],
                [:call,
                 "/",
                 [[:call, "*", [[:int, 2], [:int, 3]]],
                  [:call, "-", [[:int, 4], [:int, 2]]]]]]]
    assert_equal target, sexp
  end
end