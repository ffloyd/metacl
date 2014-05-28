module MetaCL
  module Logic
    module ExpressionTree
      class Node
        attr_accessor   :left_child, :right_child, :operator, :name, :params, :code

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

        def deep_clone
          Marshal.load(Marshal.dump(self)) # TODO: write a proper solution
        end

        def leaf?
          @leaf
        end

        def [](key)
          @params[key]
        end

        def []=(key, val)
          @params[key] = val
        end

        def nodify
          self
        end

        def nodes
          result = []
          walk { |node| result << node }
        end

        def leaves
          nodes.select(&:leaf?)
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

        def rwalk(parent = nil, &block)
          yield self, parent
          unless leaf?
            @left_child.rwalk  self, &block
            @right_child.rwalk self, &block
          end
        end

        def +(arg)
          Node.new left: self, operator: :+, right: arg.nodify
        end

        def -(arg)
          Node.new left: self, operator: :-, right: arg.nodify
        end

        def *(arg)
          Node.new left: self, operator: :*, right: arg.nodify
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