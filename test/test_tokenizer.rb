require "minitest/autorun"
require '../tokenizer'

class TestTokenizer < Minitest::Test
  def test_factorial
    code = File.open('factorial.c').read
    tokens = Tokenizer.new.tokenize(code)
    target =  [[:iden, "int"],
               [:iden, "factorial"],
               ["("],
               [:iden, "int"],
               [:iden, "n"],
               [")"],
               ["{"],
               [:if],
               ["("],
               [:iden, "n"],
               [:relational_operator, "=="],
               [:int, "1"],
               [")"],
               ["{"],
               [:return],
               [:int, "1"],
               [";"],
               ["}"],
               [:else],
               ["{"],
               [:return],
               [:iden, "n"],
               [:multiplicative_operator, "*"],
               [:iden, "factorial"],
               ["("],
               [:iden, "n"],
               [:additive_operator, "-"],
               [:int, "1"],
               [")"],
               [";"],
               ["}"],
               ["}"],
               [:iden, "int"],
               [:iden, "main"],
               ["("],
               [")"],
               ["{"],
               [:return],
               [:iden, "factorial"],
               ["("],
               [:int, "5"],
               [")"],
               [";"],
               ["}"],
               [:eof]]

    assert_equal target, tokens
  end
end