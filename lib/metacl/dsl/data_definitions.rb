module MetaCL
  module DSL
    module DataDefinitions

      def numeric(name, type, options = {})
        value = options[:value]
        @program.resources.add_numeric name, type

        @inner_code << Templates::InitNumeric.render(name, type, value, @program.platform) << "\n\n"
      end

      def array(name, type, length, options = {})
        @program.resources.add_array name, length, type

        @inner_code << Templates::InitArray.render(name, type, length, options[:fill_with], @program.platform) << "\n\n"
      end

      def matrix(name, type, size_n, size_m, options = {})
        @program.resources.add_matrix name, size_n, size_m, type

        @inner_code << Templates::InitMatrix.render(name, type, size_n, size_m, options[:fill_with], @program.platform) << "\n\n"
      end

    end
  end
end