module MetaCL
  module Templates
    class InitArray < Mustache
      attr_reader :name, :type, :length, :fill_with

      def render(name, type, length, fill_with, platform)
        @name, @type, @length, @fill_with = name, type, length, fill_with
        super IO.read("#{__dir__}/init_array.#{platform}.template")
      end
    end
  end
end