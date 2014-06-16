module MetaCL
  module Templates
    class Wrapper < Mustache
      attr_accessor :inner_code, :outer_code

      def render(inner_code, outer_code, platform)
        @inner_code, @outer_code = Utils.tab_text(inner_code), outer_code
        super IO.read("#{__dir__}/wrapper.#{platform}.template")
      end
    end
  end
end