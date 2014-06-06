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
        inner_code << "#{@result_matrix.name}[#{@n_iterator}*#{@result_matrix.m} + #{@m_iterator}] = #{@tree.get(:var)};"

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
            node.set :n, matrix.n
            node.set :m, matrix.m
          else

            case node.operator
              when :+, :-
                unless equal_if_fixnum?(node.left_child.get(:n), node.right_child.get(:n)) and equal_if_fixnum?(node.left_child.get(:m), node.right_child.get(:m))
                  raise Error::MatrixMismatchSizes
                end
                node.set :n, node.left_child.get(:n)
                node.set :m, node.left_child.get(:m)
              when :*
                unless equal_if_fixnum?(node.left_child.get(:m), node.right_child.get(:n))
                  raise Error::MatrixMismatchSizes
                end
                node.set :n, node.left_child.get(:n)
                node.set :m, node.right_child.get(:m)
                node.set :k, node.left_child.get(:m)
            end

          end
        end
        if [@result_matrix.n, @result_matrix.m] != [@tree.get(:n), @tree.get(:m)]
          raise Error::MatrixMismatchSizes
        end
      end

      def tree_type_gencheck
        @tree.walk do |node|
          if node.leaf?
            node.set :type, @matrix_manager[node.name].type
          else
            if node.left_child.get(:type) != node.right_child.get(:type)
              raise Error::MatrixMismatchTypes
            end
            node.set :type, node.left_child.get(:type)
          end
        end
        raise Error::MatrixMismatchTypes if @result_matrix.type != @tree.get(:type)
      end

      def tree_iterators_gen
        temp_idx_count = 0
        @tree.set :n_iterator, @n_iterator
        @tree.set :m_iterator, @m_iterator
        @tree.rwalk do |node|
          unless node.leaf?
            case node.operator
              when :+, :-
                [node.left_child, node.right_child].each do |nd|
                  nd.set :n_iterator, node.get(:n_iterator)
                  nd.set :m_iterator, node.get(:m_iterator)
                end
              when :*
                temp_idx_count += 1
                node.set :temp_idx, "#{@temp_idx_letter}#{temp_idx_count}"
                node.left_child.set :n_iterator,  node.get(:n_iterator)
                node.right_child.set :m_iterator, node.get(:m_iterator)

                node.left_child.set  :m_iterator, node.get(:temp_idx)
                node.right_child.set :n_iterator, node.get(:temp_idx)
            end
          end
        end
      end

      def gen_index_expr(expr, n_iterator, m_iterator)
        if expr.kind_of? Fixnum
          expr
        else
          expr.gen_string(n_iterator, m_iterator)
        end
      end

      def tree_vars_gen
        tmp_vars_count = 0
        @tree.walk do |node|
          if node.leaf?
            matrix = @matrix_manager[node.name]
            i_expr = gen_index_expr node.i_expr, node.get(:n_iterator), node.get(:m_iterator)
            j_expr = gen_index_expr node.j_expr, node.get(:n_iterator), node.get(:m_iterator)
            node.set :var, "#{node.name}[(#{i_expr})*#{matrix.m} + (#{j_expr})]"
          else
            tmp_vars_count += 1
            node.set :var, "#{@temp_var_letter}#{tmp_vars_count}"
          end
        end
      end

      # code generation

      def codegen_leaf(node)

      end

      def codegen_plus_minus(node)
        init_var  = "#{node.get(:type)} #{node.get(:var)} = #{node.left_child.get(:var)} #{node.operator} #{node.right_child.get(:var)};"
        node.code = ''
        node.code << node.left_child.code   << "\n" if node.left_child.code
        node.code << node.right_child.code  << "\n" if node.right_child.code
        node.code << init_var
      end

      def codegen_mult(node)
        init_var  = "#{node.get(:type)} #{node.get(:var)} = 0;"

        inner_code = ''
        inner_code << node.left_child.code   << "\n" if node.left_child.code
        inner_code << node.right_child.code  << "\n" if node.right_child.code
        inner_code << "#{node.get(:var)} += #{node.left_child.get(:var)} * #{node.right_child.get(:var)};"

        cycle_code = Utils.apply_template 'me_mult_wrapper', @config_manager.lang,
                                          temp_idx: node.get(:temp_idx),
                                          k: node.get(:k),
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
