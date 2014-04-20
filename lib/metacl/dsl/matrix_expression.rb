module MetaCL
  module DSL
    class MatrixExpression
      attr_accessor :tree

      def initialize(matrix_manager, config_manager, result_matrix_name, options = {}, &block)
        @matrix_manager = matrix_manager
        @config_manager = config_manager
        @result_matrix  = @matrix_manager[result_matrix_name]
        @tree = instance_eval(&block)
        prepare_tree
      end

      def prepare_tree
        temp_var_letter = 't'
        temp_var_number = 1

        tree.walk do |node|
          if node.leaf?
            @matrix_manager.check_matrix_names node.name
            matrix = @matrix_manager[node.name]
            node.params[:size] = [matrix.n, matrix.m]
          else
            # check sizes
            if node.left_child.params[:size] == node.right_child.params[:size]
              node.params[:size] = node.left_child.params[:size].dup
            else
              raise Error::MatrixMismatchSizes
            end

            # chose temp variable
            node.params[:temp_var] = "#{temp_var_letter}#{temp_var_number}"
            temp_var_number += 1
          end
        end

        raise Error::MatrixMismatchSizes unless [@result_matrix.n, @result_matrix.m] == tree.params[:size]
      end
    end
  end
end