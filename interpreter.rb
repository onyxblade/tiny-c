
class Interpreter

  module Methods
    def define_func type, name, arguments, body
      @functions[name] = [arguments.map{|x| x[1]}, body]
    end

    def define_var type, name, value = nil
      assign name, value
    end

    def call name, arguments
      #p name, arguments
      if name == '='
        return assign arguments[0][1], arguments[1]
      end

      evaluated = arguments.map{|x| self.eval(x)}
      if function = Interpreter::BASIC_FUNCTIONS[name]
        return function.call(*evaluated)
      end

      function = root_scope.functions[name]
      raise "undefined function #{name}" if function.nil?

      formal_params, body = function
      new_scope = Scope.new(self)
      formal_params.zip(evaluated).each do |name, value|
        new_scope.variables[name] = value
      end
      catch(:return) do
        body.each do |sexp|
          new_scope.eval(sexp)
        end
      end
    end

    def root_scope
      scope = self
      scope = scope.upper_scope until scope.upper_scope.nil?
      scope
    end

    def get name
      @variables[name]
    end

    def int value
      value.to_i
    end

    def float value
      value.to_f
    end

    def return expression
      result = self.eval expression
      throw :return, result
    end

    def if condition, then_body, else_body
      evaluated = self.eval condition
      if evaluated && evaluated != 0
        then_body.each{|x| self.eval x }
      else
        else_body.each{|x| self.eval x }
      end
    end

    def assign name, value
      @variables[name] = self.eval value
    end

    def eval sexp
      send(*sexp)
    end
  end

  class Scope
    attr_reader :functions, :variables, :upper_scope
    include Methods

    def initialize(upper_scope = nil)
      @upper_scope = upper_scope
      @variables = {}
      @functions = {}
    end

    def inspect
      "#<Interpreter::Scope::#{object_id} @variables=#{@variables}>"
    end
  end

  BASIC_FUNCTIONS = %w{+ - * / < > <= >= == !=}.map{|x| [x, ->(a, b){a.send(x, b)}] }.to_h

  def run sexp
    root_scope = Scope.new
    sexp.each do |function|
      root_scope.eval function
    end
    root_scope.call 'main', []
  end
end