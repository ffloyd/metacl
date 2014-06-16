module MetaCL
  module Refinements
    refine Symbol do
      def nodify
        Logic::Node.new :data, nil, nil, name: self
      end

      def +(arg)
        self.nodify + arg.nodify
      end

      def -(arg)
        self.nodify - arg.nodify
      end

      def *(arg)
        self.nodify * arg.nodify
      end

      def [](*args)
        self.nodify[*args]
      end
    end

    refine Numeric do
      def nodify
        Logic::Node.new :const, nil, nil, data: self
      end
    end
  end
end
