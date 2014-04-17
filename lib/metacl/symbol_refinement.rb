module MetaCL
  module SymbolRefinement
    refine Symbol do
      def nodify
        Logic::ExpressionTree::Node.new name: self
      end

      def +(arg)
        self.nodify + arg.nodify
      end

      def -(arg)
        self.nodify - arg.nodify
      end
    end
  end
end