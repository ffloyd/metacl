module MetaCL
  module Logic
    module ExpressionTree
      class Node
        attr_reader   :left_child, :right_child, :operator, :name, :params

        using SymbolRefinement

        def initialize(opts={})
          @params = (opts[:params] or {})
          if opts[:name]
            # leaf
            @leaf = true
            @name = opts[:name]
          elsif opts[:left] and opts[:right] and opts[:operator]
            #node
            @leaf = false
            @left_child, @right_child, @operator = opts[:left], opts[:right], opts[:operator]
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
            @left_child.leaves + @right_child.leaves
          end
        end

        def names
          leaves.map(&:name)
        end

        def walk(&block)
          unless leaf?
            @left_child.walk(&block)
            @right_child.walk(&block)
          end
          yield self
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
            "(#{@left_child.to_s}) #{@operator} (#{@right_child.to_s})"
          end
        end
      end
    end
  end
end