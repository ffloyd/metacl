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

        def reduce(init = '', &block)
          memo = init
          unless leaf?
            @left_child.walk(memo, &block)
            @right_child.walk(memo, &block)
          end
          yield memo, self
        end

        def +(arg)
          Node.new left: self, operator: :+, right: arg.nodify
        end

        def -(arg)
          Node.new left: self, operator: :-, right: arg.nodify
        end

        def print(tab = 0)
          text = ''
          params_text = @params ? "{ #{ @params.map { |k, v| "#{k}: #{v}"}.join ', ' } }" : ''
          if leaf?
            text << '  ' * tab << @name.to_s << ' ' << params_text << "\n"
          else
            text << @left_child.print(tab+1) << '  ' * tab << "operator#{@operator} " << params_text << "\n" << @right_child.print(tab+1)
          end
          text
        end

        def to_s
          print
        end
      end
    end
  end
end