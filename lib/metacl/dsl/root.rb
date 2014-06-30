module MetaCL
  module DSL
    class Root
      attr_reader :code

      include Directs
      include DataDefinitions
      include GPUTransfers

      using Refinements

      def initialize(program, filename)
        @program = program
        super() # call initializers from modules
        @inner_code     = ""
        @post_init_code = ""
        @outer_code     = ""

        instance_eval IO.read(filename), filename

        @code = Templates::Wrapper.render(@inner_code, @post_init_code, @outer_code, @program.platform)
      end

      def platform(name)
        @program.set_platform name # TODO platform check
      end

      def prints(string)
        @inner_code << Templates::Prints.render(string, @program.platform) << "\n\n"
      end

      def expression(name, *args, &block)
        tree = Expression.construct(@program, &block)
        @program.resources.add_expression(name, tree, args)
      end

      def apply_expression(matrix_name, options = {}, &block)
        expr = Expression.construct(@program, &block)
        code, init_code = ExpressionApplicator.construct(@program, expr, matrix_name, options)
        @inner_code << code << "\n\n"
        @post_init_code << init_code << "\n\n"
      end

      def print_matrix(name)
        matrix = @program.resources.matrices_hash[name]
        @inner_code << Templates::PrintMatrix.render(matrix.name, matrix.size_n, matrix.size_m, @program.platform)
      end

      def repeat(count, &block)
        @inner_code << Templates::Iterate.render(count) << "\n"
        instance_eval(&block)
        @inner_code << "}\n\n"
      end
    end
  end
end