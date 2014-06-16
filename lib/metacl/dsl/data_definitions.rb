module MetaCL
  module DSL
    module DataDefinitions

      def numeric(name, options = {})
        type  = options[:init]
        value = options[:value]
        @program.resources.add_numeric name, type

        if options[:init]
          @inner_code << Templates::InitNumeric.render(name, type, value, @program.platform) << "\n"
        end
      end

      def array(name, length, options = {})
        type = options[:init]

        @program.resources.add_array name, length, type

        if options[:init]
          @inner_code << Templates::InitArray.render(name, type, length, options[:fill_with], @program.platform) << "\n"
        end
      end

      def matrix(name, size_n, size_m, options = {})
        type = options[:init]

        @program.resources.add_array name, size_n, size_m

        if options[:init]
          @inner_code << Templates::InitMatrix.render(name, type, size_n, size_m, options[:fill_with], @program.platform) << "\n"
        end
      end

    end
  end
end