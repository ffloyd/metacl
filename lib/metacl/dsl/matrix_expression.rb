module MetaCL
  module DSL
    class MatrixExpression
      attr_accessor :tree

      def initialize(matrix_manager, &block)
        @matrix_manager = matrix_manager
        @tree = instance_eval(&block)
      end

      def check_matrices
        @matrix_manager.check_matrices tree.names
      end
    end
  end
end