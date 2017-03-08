class Compiler
  class Scope

  end

  def compile(sexp)
    sexp.each do |function|
      analyze functions
    end
  end
end