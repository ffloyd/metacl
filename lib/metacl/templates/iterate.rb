module MetaCL
  module Templates
    class Iterate < Mustache
      @@counter = 0
      attr_reader :counter, :repeats

      def render(repeats)
        @@counter += 1
        @counter = @@counter
        @repeats = repeats
        #@code = Utils.tab_text(code, 1)
        super IO.read("#{__dir__}/iterate.any.template")
      end
    end
  end
end