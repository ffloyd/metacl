module MetaCL
  module DSL
    class ExpressionApplicator
      @@counter = 0
      attr_reader :code, :init_code

      def initialize(program, expr, result_matrix, options = {})
        @@counter += 1
        @program = program
        @expr = if expr.kind_of? Logic::Node
                  expr.deep_clone
                elsif expr.kind_of? Symbol
                  Logic::Node.new :data, nil, nil, name: expr
                elsif expr.kind_of? Numeric
                  Logic::Node.new :const, nil, nil, data: expr
                end
        @result_matrix  = program.resources.matrices_hash[result_matrix]

        @left_border  = options[:from]  || [0, 0]
        @right_border = options[:to]    || [@result_matrix.size_n, @result_matrix.size_m]

        @var_letter   = 't'

        prepare_tree
        code_generation

        @init_code = if @program.platform == :cl
                       Templates::KernelInit.render(@left_border, @right_border, @expr.params.code || '', @result_matrix, @expr.objects, @@counter, @program.platform)
                     else
                       ''
                     end
        @code = Templates::ExpressionApplicatorWrapper.render(@left_border, @right_border, @expr.params.code || '', @expr.objects, @result_matrix, @@counter, @program.platform)
      end

      def self.construct(program, expr, result_matrix, options = {})
        e = ExpressionApplicator.new(program, expr, result_matrix, options)
        [e.code, e.init_code]
      end

      def prepare_tree
        pt_vars_gen
      end

      # pt means prepare_tree

      def pt_vars_gen
        vars_count = 0

        @expr.walk do |node|
          case node.type
            when :data
              index_i = node.params.index_i || 'i'
              index_j = node.params.index_j || 'j'
              data    = @program.resources[node.params.name]
              node.params.object = data
              case data.klass
                when :matrix
                  node.params.var = "#{data.name}[(#{index_i})*#{data.size_m} + (#{index_j})]"
                when :array
                  node.params.var = "#{data.name}[#{index_i}]"
                when :numeric
                  node.params.var = data.name
              end
            when :operator, :aggregator
              vars_count += 1
              node.params.var = @var_letter + vars_count.to_s
            when :const
              node.params.var = node.params.data.to_s
          end
        end
      end

      def code_generation
        @expr.walk do |node|
          case node.type
            when :operator
              left_var    = node.left_child.params.var
              right_var   = node.right_child.params.var
              left_code   = node.left_child.params.code   || ''
              right_code  = node.right_child.params.code  || ''
              node.params.code = left_code + right_code + "float #{node.params.var} = #{left_var} #{node.params.type} #{right_var};\n"
            when :aggregator
              code          = node.left_child.params.code || ''
              subresult_var = node.left_child.params.var
              iterator      = node.params.index
              from, to      = node.params.from, node.params.to
              type          = 'float'
              var           = node.params.var
              operator      = node.params.type
              node.params.code = Templates::Aggregator.render(@program.platform,
                                                              code: code,
                                                              subresult_var: subresult_var,
                                                              iterator: iterator,
                                                              from: from,
                                                              to: to,
                                                              type: type,
                                                              var: var,
                                                              operator: operator
              ) + "\n"
          end
        end

        @expr.params.code ||= ''
        @expr.params.code += "#{@result_matrix.name}[i*#{@result_matrix.size_m} + j] = #{@expr.params.var};\n"
      end
    end
  end
end