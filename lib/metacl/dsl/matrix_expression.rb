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
        @temp_idx_letter  = options[:temp_var_letter] || 'k'

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
            node.params[:type] = matrix.type
          else
            # check sizes
            if node.left_child.params[:size] == node.right_child.params[:size]
              node.params[:size] = node.left_child.params[:size].dup
            else
              raise Error::MatrixMismatchSizes
            end

            # chose temp variable
            node.params[:var]   = "#{@temp_var_letter}#{temp_var_number}"
            node.params[:type]  = node.left_child.params[:type]
            temp_var_number += 1
          end
        end

        raise Error::MatrixMismatchSizes if [@result_matrix.n, @result_matrix.m] != tree.params[:size]
      end

      def code_generation
        # indexes generation
        @tree.rwalk do |node, parent|
          n_iterator, m_iterator =  if parent
                                      [ parent.params[:n_iterator], parent.params[:m_iterator] ]
                                    else
                                      [ @n_iterator, @m_iterator ]
                                    end
          node.params[:n_iterator] = n_iterator
          node.params[:m_iterator] = m_iterator
        end

        @tree.walk do |node|
          if node.leaf?
            matrix = @matrix_manager[node.name]
            node.params[:var]   = "#{node.name}[#{node.params[:n_iterator]}*#{matrix.m} + #{node.params[:m_iterator]}]"
          else
            if [:+, :-].include? node.operator
              node.params[:code] = node.left_child.params[:code].to_s + node.right_child.params[:code].to_s
              node.params[:code]  << "#{node.params[:type]} #{node.params[:var]} = #{node.left_child.params[:var]} #{node.operator} #{node.right_child.params[:var]};\n"
            end
          end
        end

        inner_code = @tree.params[:code] || @tree.params[:var]
        inner_code << "#{@result_matrix.name}[#{@n_iterator}*#{@result_matrix.m} + #{@m_iterator}] = #{@tree.params[:var]};\n"
        inner_code = Utils.tab_text(inner_code, 2)
        @code = Utils.apply_template('me_wrapper', @config_manager.lang,
                                     n_iterator: 'i',
                                     m_iterator: 'j',
                                     n: @result_matrix.n,
                                     m: @result_matrix.m,
                                     code: inner_code)
      end
    end
  end
end