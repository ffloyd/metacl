module MetaCL
  module DSL
    class Root
      attr_reader :code

      include Directs

      def initialize(program, filename)
        @program = program
        super() # call initializers from modules
        @inner_code = ""
        @outer_code = ""

        instance_eval IO.read(filename), filename

        @code = Templates::Wrapper.render(@inner_code, @outer_code, @program.platform)
      end

      def platform(name)
        @program.set_platform name # TODO platform check
      end

      def prints(string)
        @inner_code << Templates::Prints.render(string, @program.platform) << "\n"
      end
    end
  end
end