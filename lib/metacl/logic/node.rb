module MetaCL
  module Logic
    class Node
      using Refinements
      attr_reader   :type, :params, :left_child, :right_child

      def initialize(type, left_child = nil, right_child = nil, params = {})
        @type = type
        @params = OpenStruct.new(params)
        @left_child, @right_child = left_child, right_child
      end

      def deep_clone
        Marshal.load(Marshal.dump(self)) # TODO: write a proper solution
      end

      def leaf?
        not (left_child or right_child)
      end

      def nodify
        self
      end

      def [](index_i, index_j = nil)
        params.index_i = index_i
        params.index_j = index_j
        self
      end

      def walk(&block)
        @left_child.walk(&block)  if @left_child
        @right_child.walk(&block) if @right_child
        yield self
      end

      def nodes
        result = []
        walk { |node| result << node }
      end

      def leaves
        nodes.select(&:leaf?)
      end

      def +(arg)
        Node.new :operator, self, arg.nodify, type: :+
      end

      def -(arg)
        Node.new :operator, self, arg.nodify, type: :-
      end

      def /(arg)
        Node.new :operator, self, arg.nodify, type: :/
      end

      def *(arg)
        Node.new :operator, self, arg.nodify, type: :*
      end

      def debug(tab = 0)
        text = '  ' * tab << @type.to_s << ' ' << "{ #{ @params.to_h.map { |k, v| "#{k}: #{v}"}.join ', ' } }" << "\n"
        if @left_child
          text << '  ' * tab << "left: \n"
          text << @left_child.debug(tab+1)
        end
        if @right_child
          text << '  ' * tab << "right: \n"
          text << @right_child.debug(tab+1)
        end
        text
      end

      def to_s
        debug
      end

      def get_tree_with_substitution(subst)
        new_tree = self.deep_clone
        new_tree.leaves.each do
          |leaf| leaf.params.name = subst[leaf.params.name]
        end
        new_tree
      end
    end
  end
end