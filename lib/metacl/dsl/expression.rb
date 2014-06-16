module MetaCL
  module DSL
    class Expression
      attr_reader :tree

      def initialize(program, &block)
        @program = program
        @tree = instance_eval(&block)
      end

      def method_missing(name, *args)
        sub_expression = @program.resources.expressions_hash[name.to_sym]
        substitution = sub_expression.args.map.with_index { |param, index| [param, args[index]] }.to_h
        sub_expression.root_node.get_tree_with_substitution(substitution)
      end

      def self.construct(program, &block)
        Expression.new(program, &block).tree
      end
    end
  end
end