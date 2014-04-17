module MetaCL
  module DSL
    class MatrixExpression
      attr_accessor :tree

      def initialize(&block)
        @tree = instance_eval(&block)
      end
    end
  end
end