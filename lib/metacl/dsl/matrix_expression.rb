module MetaCL
  module DSL
    class MatrixExpression
      attr_accessor :tree, :code

      def initialize(matrix_manager, config_manager, partial_manager, result_matrix_name, options = {}, &block)
        @matrix_manager   = matrix_manager
        @config_manager   = config_manager
        @partial_manager  = partial_manager
        @result_matrix    = @matrix_manager[result_matrix_name]

        @n_iterator       = options[:n_iterator]      || 'i'
        @m_iterator       = options[:m_iterator]      || 'j'
        @temp_var_letter  = options[:temp_var_letter] || 't'
        @temp_idx_letter  = options[:temp_idx_letter] || 'k'

        @from = options[:from] || [0, 0]
        @to   = options[:to]   || [@result_matrix.n, @result_matrix.m]

        @tree = PartialExpression.new(partial_manager, &block).tree
        prepare_tree
        code_generation
      end

      private

      def prepare_tree
        border_check
        tree_names_check
        tree_operators_check
        tree_type_gencheck
        tree_size_gencheck
        tree_iterators_gen
        tree_vars_gen
      end

      def code_generation
        @tree.walk do |node|
          if node.leaf?
            codegen_leaf(node)
          else
            case node.operator
              when :+, :-
                codegen_plus_minus(node)
              when :*
                codegen_mult(node)
            end
          end
        end

        inner_code = ''
        inner_code << @tree.code << "\n"
        inner_code << "#{@result_matrix.name}[#{@n_iterator}*#{@result_matrix.m} + #{@m_iterator}] = #{@tree[:var]};"

        @code = Utils.apply_template 'me_wrapper', @config_manager.lang,
                                     n_iterator: @n_iterator,
                                     m_iterator: @m_iterator,
                                     from: @from,
                                     to:   @to,
                                     code: Utils.tab_text(inner_code, 2)
      end

      # tree preparation methods

      def tree_names_check
        @matrix_manager.check_matrix_names @tree.names
      end

      def tree_operators_check
        operators = @tree.nodes.map(&:operator).uniq
        if (operators - %i[+ - *]).any?
          raise Error::UnknownOperator
        end
      end

      def equal_if_fixnum?(x, y)
        if x.is_a? Fixnum and y.is_a? Fixnum
          (x == y)
        else
          true
        end
      end

      def tree_size_gencheck
        @tree.walk do |node|
          if node.leaf?
            matrix = @matrix_manager[node.name]
            node[:n], node[:m] = matrix.n, matrix.m
          else

            case node.operator
              when :+, :-
                unless equal_if_fixnum?(node.left_child[:n], node.right_child[:n]) and equal_if_fixnum?(node.left_child[:m], node.right_child[:m])
                  raise Error::MatrixMismatchSizes
                end
                node[:n], node[:m] = node.left_child[:n], node.left_child[:m]
              when :*
                unless equal_if_fixnum?(node.left_child[:m], node.right_child[:n])
                  raise Error::MatrixMismatchSizes
                end
                node[:n], node[:m]  = node.left_child[:n], node.right_child[:m]
                node[:k] = node.left_child[:m]
            end

          end
        end
        if [@result_matrix.n, @result_matrix.m] != [@tree[:n], @tree[:m]]
          raise Error::MatrixMismatchSizes
        end
      end

      def tree_type_gencheck
        @tree.walk do |node|
          if node.leaf?
            node[:type] = @matrix_manager[node.name].type
          else
            if node.left_child[:type] != node.right_child[:type]
              raise Error::MatrixMismatchTypes
            end
            node[:type] = node.left_child[:type]
          end
        end
        raise Error::MatrixMismatchTypes if @result_matrix.type != @tree[:type]
      end

      def tree_iterators_gen
        temp_idx_count = 0
        @tree[:n_iterator], @tree[:m_iterator] = @n_iterator, @m_iterator
        @tree.rwalk do |node|
          unless node.leaf?
            case node.operator
              when :+, :-
                [node.left_child, node.right_child].each do |nd|
                  nd[:n_iterator], nd[:m_iterator] = node[:n_iterator], node[:m_iterator]
                end
              when :*
                temp_idx_count += 1
                node[:temp_idx] = "#{@temp_idx_letter}#{temp_idx_count}"
                node.left_child[:n_iterator], node.right_child[:m_iterator] = node[:n_iterator], node[:m_iterator]
                node.left_child[:m_iterator] = node.right_child[:n_iterator] = node[:temp_idx]
            end
          end
        end
      end

      def tree_vars_gen
        tmp_vars_count = 0
        @tree.walk do |node|
          if node.leaf?
            matrix = @matrix_manager[node.name]
            node[:var] = "#{node.name}[#{node[:n_iterator]}*#{matrix.m} + #{node[:m_iterator]}]"
          else
            tmp_vars_count += 1
            node[:var] = "#{@temp_var_letter}#{tmp_vars_count}"
          end
        end
      end

      # code generation

      def codegen_leaf(node)

      end

      def codegen_plus_minus(node)
        init_var  = "#{node[:type]} #{node[:var]} = #{node.left_child[:var]} #{node.operator} #{node.right_child[:var]};"
        node.code = ''
        node.code << node.left_child.code   << "\n" if node.left_child.code
        node.code << node.right_child.code  << "\n" if node.right_child.code
        node.code << init_var
      end

      def codegen_mult(node)
        init_var  = "#{node[:type]} #{node[:var]} = 0;"

        inner_code = ''
        inner_code << node.left_child.code   << "\n" if node.left_child.code
        inner_code << node.right_child.code  << "\n" if node.right_child.code
        inner_code << "#{node[:var]} += #{node.left_child[:var]} * #{node.right_child[:var]};"

        cycle_code = Utils.apply_template 'me_mult_wrapper', @config_manager.lang,
                                          temp_idx: node[:temp_idx],
                                          k: node[:k],
                                          code: Utils.tab_text(inner_code)
        node.code = ''
        node.code << init_var << "\n"
        node.code << cycle_code
      end

      def correct_border(x, b_name)
        return true unless x.is_a? Fixnum
        x >= 0 and x <= @result_matrix.send(b_name)
      end

      def border_check
        correct_from    = correct_border(@from[0], :n) and correct_border(@from[1], :m)
        correct_to      = correct_border(@to[0], :n)   and correct_border(@to[1], :m)
        unless correct_from and correct_to
          raise Error::InvalidBorders
        end
      end
    end
  end
end
