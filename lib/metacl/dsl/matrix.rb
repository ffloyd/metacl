require 'metacl/utils'

module MetaCL
  module DSL
    module Matrix
      ALLOWED_MATRIX_TYPES = %i[int float double]

      def initialize
        @matrices = {}
      end

      def create_matrix(name, type, n, m)
        name_sym, type_sym = name.to_sym, type.to_sym

        # check correctness
        unless ALLOWED_MATRIX_TYPES.include? type_sym
          raise "Incorrect matrix type '#{type}'. Allowed types is #{ALLOWED_MATRIX_TYPES.join(', ')}."
        end
        if @matrices.has_key? name_sym
          raise "You cannot create matrix with same name twice."
        end
        unless n.is_a?(Fixnum) and m.is_a?(Fixnum)
          raise "N and M must be integers."
        end

        @code << Utils.apply_template('create_matrix', @lang,
                                      name: name,
                                      type: type,
                                      n: n,
                                      m: m) << "\n"
        @matrices[name_sym] = MatrixObject.new(name_sym, type_sym, n, m)
      end

      def destroy_matrix(name)
        name_sym = name.to_sym
        raise "Cannot destroy nonexistent matrix with name '#{name_sym}'." unless @matrices.has_key? name_sym
        @code << Utils.apply_template('destroy_matrix', @lang, name: name) << "\n"
        @matrices.delete name_sym
      end

      def fill_matrix_with(name, &block)
        name_sym = name.to_sym
        raise "Cannot fill nonexistent matrix with name '#{name_sym}'." unless @matrices.has_key? name_sym
        @code << MatrixFiller.new(@lang, name_sym, @matrices, &block).code
      end

      def print_matrix(name)
        name_sym = name.to_sym
        @code << Utils.apply_template('print_matrix', @lang,
                                      name: name_sym,
                                      n: @matrices[name_sym].n,
                                      m: @matrices[name_sym].m) << "\n"
      end
    end

    class MatrixObject
      attr_reader :name, :type, :n, :m
      attr_writer :code_context

      def initialize(name, type, n, m)
        @name, @type, @n, @m = name, type, n, m
      end

      def value_in_context
        "#{@name}[#{@code_context.n_iterator} + #{n}*#{@code_context.m_iterator}]"
      end

      def +(operand)
        VirtualMatrixObject.new "(#{value_in_context} + #{operand.value_in_context})"
      end

      def -(operand)
        VirtualMatrixObject.new "(#{value_in_context} - #{operand.value_in_context})"
      end
    end

    class VirtualMatrixObject
      attr_reader :value_in_context

      def initialize(value)
        @value_in_context = value
      end

      def +(operand)
        VirtualMatrixObject.new "(#{value_in_context} + #{operand.value_in_context})"
      end

      def -(operand)
        VirtualMatrixObject.new "(#{value_in_context} - #{operand.value_in_context})"
      end
    end

    class MatrixExpressionContext
      attr_reader :used_iterators, :code, :n_iterator, :m_iterator

      def initialize(n_iterator, m_iterator)
        @used_iterators, @code, @n_iterator, @m_iterator = 0, '', n_iterator, m_iterator
      end
    end

    class MatrixFiller
      attr_reader :code

      def initialize(lang, name, matrices, &block)
        @lang, @name, @matrices, @code = lang, name.to_sym, matrices, ''
        @context = MatrixExpressionContext.new(:i, :j)
        raw_result = instance_eval(&block)
        result  = if raw_result.respond_to? :value_in_context
                    raw_result.value_in_context
                  else
                    raw_result
                  end
        @code << Utils.apply_template('matrix_filler', @lang,
                                      n_iterator: 'i',
                                      m_iterator: 'j',
                                      matrix_name: name,
                                      n: @matrices[name].n,
                                      m: @matrices[name].m,
                                      expression: result) << "\n"
      end

      def method_missing(name, *args)
        if name =~ /\Am_/ and @matrices.has_key?(matrix_name = name[2..-1].to_sym)
          @matrices[matrix_name].tap { |m| m.code_context = @context}
        else
          super
        end
      end
    end
  end
end