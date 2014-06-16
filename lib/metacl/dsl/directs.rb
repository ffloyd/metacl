module MetaCL
  module DSL
    module Directs
      def direct(string)
        @inner_code << string << "\n"
      end

      def direct_pre(string)
        @outer_code << string << "\n"
      end
    end
  end
end