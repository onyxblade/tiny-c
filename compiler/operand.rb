class Compiler
  class Operand
    class Value < Operand
      def initialize value
        @value = value
      end

      def can_store?
        false
      end

      def to_s
        "$#{@value}"
      end
    end

    class Register < Operand
      attr_reader :name
      def initialize name, manager
        @name = name
        @manager = manager
      end

      def to_s
        "%#{name}"
      end

      def can_store?
        true
      end

      def finish
        @manager.registers[name] = false
      end
    end

    class PushedRegister < Operand
      attr_reader :name

      def initialize name, manager
        @name = name
        @manager = manager
      end

      def to_s
        "%#{name}"
      end

      def can_store?
        false
      end

      def finish
        @manager.asm.puts "pop #{to_s}"
      end
    end
  end

end