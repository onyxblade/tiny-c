require_relative './compiler/operand'

class Compiler
  class Scope
    attr_reader :variables

    def +(a, b)
      a = analyze a
      @asm.puts "push #{a}"
      b = analyze b
      @asm.puts "mov #{b}, %rdx"
      @asm.puts "pop %rax"
      @asm.puts "add %rdx, %rax"
      "%rax"
    end

    def -(a, b)
      a = analyze a
      @asm.puts "push #{a}"
      b = analyze b
      @asm.puts "mov #{b}, %rdx"
      @asm.puts "pop %rax"
      @asm.puts "sub %rdx, %rax"
      "%rax"
    end

    def *(a, b)
      a = analyze a
      @asm.puts "push #{a}"
      b = analyze b
      @asm.puts "mov #{b}, %rdx"
      @asm.puts "pop %rax"
      @asm.puts "imul %rdx, %rax"
      "%rax"
    end

    def /(a, b)
      a = analyze a
      @asm.puts "push #{a}"
      b = analyze b
      @asm.puts "mov #{b}, %rcx"
      @asm.puts "pop %rax"
      @asm.puts "cltd"
      @asm.puts "idiv %rcx"
      "%rax"
    end

    def ==(a, b)
      a = analyze a
      @asm.puts "push #{a}"
      b = analyze b
      @asm.puts "mov #{b}, %rdx"
      @asm.puts "pop %rax"
      @asm.puts "cmp %rdx, %rax"
      @asm.puts "sete \%al"
      @asm.puts "movzbq \%al, %rax"
      "%rax"
    end

    def <=(a, b)

    end

    def <(a, b)

    end

    def >(a, b)

    end

    def >=(a, b)

    end

    def !=(a, b)

    end

    def return n
      n = analyze n
      if n != "%rax"
        @asm.puts "mov #{n}, %rax"
      end
      @asm.puts "leave"
      @asm.puts "ret"
    end

    def define_func type, name, arguments, body
      scope = Scope.new(@asm)
      arguments.reverse.each_with_index do |arg, i|
        scope.variables[arg[1]] = "#{16 + i * 8}(%rbp)"
      end
      @asm.puts "#{name}:"
      @asm.puts "push %rbp"
      @asm.puts "mov %rsp, %rbp"
      body.each{|x| scope.analyze x}
    end

    def call name, arguments
      if %w{+ - * / == != <= >= < >}.include? name
        send(name, *arguments)
      else
        arguments.each do |arg|
          @asm.puts "push #{analyze arg}"
        end
        @asm.puts "call #{name}"
        @asm.puts "add $#{arguments.size * 8}, %rsp"
        "%rax"
      end
    end

    def int n
      "$#{n}"
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

    def if condition, then_body, else_body = []
      tag_name = Random.rand(2 ** 32)
      cond = analyze condition
      @asm.puts "cmp $0, #{cond}"
      @asm.puts "je else#{tag_name}"
      then_body.each{|sexp| analyze sexp}
      @asm.puts "jmp done#{tag_name}"
      @asm.puts "else#{tag_name}:"
      else_body.each{|sexp| analyze sexp}
      @asm.puts "done#{tag_name}:"
    end

    def initialize asm
      @asm = asm
      @variables = {}
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