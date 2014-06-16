module MetaCL
  module Templates
    class InitNumeric < Mustache
      attr_accessor :name, :type, :value

      def render(name, type, value, platform)
        @name, @type, @value = name, type, value
        super IO.read("#{__dir__}/init_numeric.#{platform}.template")
      end
    end
  end
end