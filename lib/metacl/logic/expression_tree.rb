module MetaCL
  module Logic
    module ExpressionTree
      class Node
        attr_reader :left_node, :right_node, :operator, :name, :offsets

        using SymbolRefinement

        def initialize(opts={})
          if opts[:name]
            # leaf
            @leaf = true
            @name, @offsets = opts[:name], opts[:offsets]
          elsif opts[:left] and opts[:right] and opts[:operator]
            #node
            @leaf = false
            @left_node, @right_node, @operator = opts[:left], opts[:right], opts[:operator]
          end
        end

        def leaf?
          @leaf
        end

        def nodify
          self
        end

        def +(arg)
          Node.new left: self, operator: :+, right: arg.nodify
        end

        def -(arg)
          Node.new left: self, operator: :-, right: arg.nodify
        end

        def to_s
          if leaf?
            @name
          else
            "(#{@left_node.to_s}) #{@operator} (#{@right_node.to_s})"
          end
        end
      end
    end
  end
end