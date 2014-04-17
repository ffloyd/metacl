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
            @name, @params = opts[:name], opts[:params]
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

        def leaves
          if leaf?
            [self]
          else
            @left_node.leaves + @right_node.leaves
          end
        end

        def names
          leaves.map(&:name)
        end

        def +(arg)
          Node.new left: self, operator: :+, right: arg.nodify
        end

        def -(arg)
          Node.new left: self, operator: :-, right: arg.nodify
        end

        def to_s
          if leaf?
            if @params
              "#{@name}[#{ @params.map { |k, v| "#{k}: #{v}"}.join ', ' }]"
            else
              "#{@name}"
            end
          else
            "(#{@left_node.to_s}) #{@operator} (#{@right_node.to_s})"
          end
        end
      end
    end
  end
end