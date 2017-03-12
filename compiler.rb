
class Compiler
  class Scope
    attr_reader :variables, :var_index
    def self.arithmetic_operation name, asm_operator
      define_method(name) do |a, b|
        a = analyze a
        @asm.puts "pushq #{a}"
        b = analyze b
        @asm.puts "movq #{b}, %rdx"
        @asm.puts "popq %rax"
        @asm.puts "#{asm_operator}q %rdx, %rax"
        "%rax"
      end
    end

    def self.relational_operation name, asm_operator
      define_method(name) do |a, b|
        a = analyze a
        @asm.puts "pushq #{a}"
        b = analyze b
        @asm.puts "movq #{b}, %rdx"
        @asm.puts "popq %rax"
        @asm.puts "cmpq %rdx, %rax"
        @asm.puts "#{asm_operator} \%al"
        @asm.puts "movzbq \%al, %rax"
        "%rax"
      end
    end

    arithmetic_operation :+, :add
    arithmetic_operation :-, :sub
    arithmetic_operation :*, :imul

    def /(a, b)
      a = analyze a
      @asm.puts "pushq #{a}"
      b = analyze b
      @asm.puts "movq #{b}, %rcx"
      @asm.puts "popq %rax"
      @asm.puts "cltd"
      @asm.puts "idivq %rcx"
      "%rax"
    end

    relational_operation :==, :sete
    relational_operation :!=, :setne
    relational_operation :<, :setl
    relational_operation :>, :setg
    relational_operation :<=, :setle
    relational_operation :>=, :setge

    def return n
      n = analyze n
      if n != "%rax"
        @asm.puts "movq #{n}, %rax"
      end
      @asm.puts "addq $#{@var_index * 8}, %rsp" if @var_index >= 0
      @asm.puts "leave"
      @asm.puts "ret"
    end

    def define_func type, name, arguments, body
      buffer = StringIO.new
      scope = Scope.new(buffer)
      arguments.reverse.each_with_index do |arg, i|
        scope.variables[arg[1]] = "#{16 + i * 8}(%rbp)"
      end
      @asm.puts "#{name}:"
      @asm.puts "pushq %rbp"
      @asm.puts "movq %rsp, %rbp"
      body.each{|x| scope.analyze x}
      @asm.puts "subq $#{scope.var_index * 8}, %rsp"
      buffer.string.lines.each{|line| @asm.puts line}
    end

    def call name, arguments
      if %w{+ - * / == != <= >= < >}.include? name
        send(name, *arguments)
      else
        arguments.each do |arg|
          @asm.puts "pushq #{analyze arg}"
        end
        @asm.puts "call #{name}"
        @asm.puts "addq $#{arguments.size * 8}, %rsp"
        "%rax"
      end
    end

    def int n
      "$#{n}"
    end

    def inc name
      @asm.puts "incq #{get name}"
    end

    def dec name
      @asm.puts "decq #{get name}"
    end

    def analyze sexp
      if sexp.is_a? Array
        send(*sexp)
      else
        sexp
      end
    end

    def get name
      @variables[name]
    end

    def assign name, value
      value = analyze value
      @asm.puts "movq #{value}, #{get(name)}"
    end

    def define_var type, name, value = nil
      @variables[name] = "-#{@var_index * 8}(%rbp)"
      @var_index += 1
      assign name, value if value
    end

    def if condition, then_body, else_body = []
      tag_name = Random.rand(2 ** 32)
      cond = analyze condition
      @asm.puts "cmpq $0, #{cond}"
      @asm.puts "je else#{tag_name}"
      then_body.each{|sexp| analyze sexp}
      @asm.puts "jmp done#{tag_name}"
      @asm.puts "else#{tag_name}:"
      else_body.each{|sexp| analyze sexp}
      @asm.puts "done#{tag_name}:"
    end

    def for init, cond, step, body
      tag_name = Random.rand(2 ** 32)
      analyze init
      @asm.puts "begin#{tag_name}:"
      cond = analyze cond
      @asm.puts "cmpq $0, #{cond}"
      @asm.puts "je exit#{tag_name}"
      body.each{|sexp| analyze sexp}
      #step.each{|sexp| analyze sexp}
      analyze step
      @asm.puts "jmp begin#{tag_name}"
      @asm.puts "exit#{tag_name}:"
    end

    def while cond, body
      tag_name = Random.rand(2 ** 32)
      @asm.puts "begin#{tag_name}:"
      cond = analyze cond
      @asm.puts "cmpq $0, #{cond}"
      @asm.puts "je exit#{tag_name}"
      body.each{|sexp| analyze sexp}
      @asm.puts "jmp begin#{tag_name}"
      @asm.puts "exit#{tag_name}:"
    end

    def initialize asm
      @asm = asm
      @variables = {}
      @var_index = 0
    end
  end

  def compile(sexp)
    @asm = StringIO.new
    @asm.puts ".text"
    @asm.puts ".global main"
    @asm.puts

    scope = Scope.new(@asm)

    sexp.map do |function|
      scope.analyze(function)
    end
    @asm.string
  end
end