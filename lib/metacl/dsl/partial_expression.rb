module MetaCL
  module DSL
    class PartialExpression
      attr_accessor :tree

      def initialize(partial_manager, name = nil, params = nil, &block)
        @partial_manager = partial_manager

        @tree = instance_eval(&block)

        if name and params
          @partial_manager.add_partial(name.to_sym, params, @tree)
        end
      end

      def method_missing(name, *args)
        partial = @partial_manager[name.to_sym]
        substitution = partial.params.map.with_index { |param, index| [param, args[index]] }.to_h
        partial.get_tree_with_substitution(substitution)
      end
    end
  end
end