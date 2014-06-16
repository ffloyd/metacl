module MetaCL
  module Templates
    class InitMatrix < Mustache
      attr_accessor :name, :type, :size_n, :size_m, :fill_with

      def render(name, type, size_n, size_m, fill_with, platform)
        @name, @type, @size_n, @size_m, @fill_with = name, type, size_n, size_m, fill_with
        super IO.read("#{__dir__}/init_matrix.#{platform}.template")
      end
    end
  end
end