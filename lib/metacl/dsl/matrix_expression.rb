module MetaCL
  module DSL
    class MatrixExpression
      attr_accessor :tree, :code

      def initialize(matrix_manager, config_manager, result_matrix_name, options = {}, &block)
        @matrix_manager = matrix_manager
        @config_manager = config_manager
        @result_matrix  = @matrix_manager[result_matrix_name]

        @n_iterator       = options[:n_iterator]      || 'i'
        @m_iterator       = options[:m_iterator]      || 'j'
        @temp_var_letter  = options[:temp_var_letter] || 't'

        @tree = instance_eval(&block)
        prepare_tree
        code_generation
      end

      private

      def prepare_tree
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
            node.params[:var] = "#{@temp_var_letter}#{temp_var_number}"
            temp_var_number += 1
          end
        end

        raise Error::MatrixMismatchSizes if [@result_matrix.n, @result_matrix.m] != tree.params[:size]
      end

      def code_generation
        @tree.walk do |node|
          if node.leaf?
            matrix = @matrix_manager[node.name]
            node.params[:var]   = "#{node.name}[#{@n_iterator}*#{matrix.m} + #{@m_iterator}]"
          else
            node.params[:code] = node.left_child.params[:code].to_s + node.right_child.params[:code].to_s
            node.params[:code]  << "#{node.params[:var]} = #{node.left_child.params[:var]} #{node.operator} #{node.right_child.params[:var]};\n"
          end
        end

        inner_code = Utils.tab_text(@tree.params[:code] || @tree.params[:var], 2)
        @code = Utils.apply_template('me_wrapper', @config_manager.lang, n_index: 'i', m_index: 'j', n: @result_matrix.n, m: @result_matrix.m, code: inner_code)
      end
    end
  end
end