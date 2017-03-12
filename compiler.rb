require_relative './compiler/operand'

class Compiler
  class Scope
    attr_reader :variables
  end

  module Primitives
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
  end
  include Primitives

  def return n
    n = analyze n
    if n != "%rax"
      @asm.puts "mov #{n}, %rax"
    end
    @asm.puts "leave"
    @asm.puts "ret"
  end

  def define_func type, name, arguments, body
    variables = {}

    @asm.puts "#{name}:"
    @asm.puts "push %rbp"
    @asm.puts "mov %rsp, %rbp"
    body.each{|x| analyze x}

  end

  def call name, arguments
    if %w{+ - * /}.include? name
      send(name, *arguments)
    end
  end

  def int n
    #Operand::Value.new(n)
    "$#{n}"
  end

  def analyze sexp
    if sexp.is_a? Array
      send(*sexp)
    else
      sexp
    end
  end

  def store_result
    if name = @register_manager.get_available_register
      Register.new(name)
    else
      ValueOnStack.new
    end
  end

  def retrieve_result

  end

  def compile(sexp)
    @asm = StringIO.new
    @asm.puts ".text"
    @asm.puts ".global main"
    @asm.puts

    sexp.map do |function|
      analyze(function)
    end
    @asm.string
  end
end