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
end