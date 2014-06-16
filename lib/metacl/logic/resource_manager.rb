module MetaCL
  module Logic
    class ResourceManager
      def initialize
        @namespace = {}
      end

      def add_numeric(name, type = nil) # name check
        @namespace[name] = OpenStruct.new(name: name, klass: :numeric, type: type)
      end

      def add_array(name, length, type = nil) # name check
        @namespace[name] = OpenStruct.new(name: name, klass: :array, type: type, length: length)
      end

      def add_matrix(name, size_n, size_m, type = nil)
        @namespace[name] = OpenStruct.new(name: name, klass: :matrix, type: type, size_n: size_n, size_m: size_m)
      end

      def add_expression(name, root_node, args = [])
        @namespace[name] = OpenStruct.new(name: name, klass: :expression, args: args, root_node: root_node)
      end

      def numerics
        @namespace.values.select { |e| e.klass == :numeric }
      end

      def arrays
        @namespace.values.select { |e| e.klass == :array }
      end

      def matrices
        @namespace.values.select { |e| e.klass == :matrix }
      end

      def expressions
        @namespace.values.select { |e| e.klass == :expression }
      end

      def expressions_hash
        Hash[expressions.map { |e| [e.name, e] }]
      end

      def [](arg)
        @namespace[arg]
      end
    end
  end
end