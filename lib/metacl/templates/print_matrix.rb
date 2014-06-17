module MetaCL
  module Templates
    class PrintMatrix < Mustache
      attr_reader :size_n, :size_m, :matrix_name

      def render(matrix_name, size_n, size_m, platform)
        @size_n, @size_m, @matrix_name = size_n, size_m, matrix_name

        super IO.read("#{__dir__}/print_matrix.#{platform}.template")
      end
    end
  end
end