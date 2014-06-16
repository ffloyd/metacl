module MetaCL
  module Templates
    class Prints < Mustache
      attr_accessor :string

      def render(string, platform)
        @string = string
        super IO.read("#{__dir__}/prints.#{platform}.template")
      end
    end
  end
end