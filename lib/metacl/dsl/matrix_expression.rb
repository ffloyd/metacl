module MetaCL
  module DSL
    class MatrixExpression
      attr_accessor :tree

      def initialize(matrix_manager, result_matrix_name, &block)
        @matrix_manager = matrix_manager
        @result_matrix  = @matrix_manager[result_matrix_name]
        @tree = instance_eval(&block)
        check_matrices
      end

      def check_matrices
        @matrix_manager.check_matrix_names tree.names

        # check sizes
        tree.walk do |node|
          if node.leaf?
            matrix = @matrix_manager[node.name]
            node.params[:size] = [matrix.n, matrix.m]
          else
            if node.left_child.params[:size] == node.right_child.params[:size]
              node.params[:size] = node.left_child.params[:size].dup
            else
              raise Error::MatrixMismatchSizes
            end
          end
        end

        raise Error::MatrixMismatchSizes unless [@result_matrix.n, @result_matrix.m] == tree.params[:size]
      end
    end
  end
end