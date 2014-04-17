module MetaCL
  module DSL
    using SymbolRefinement

    class Main
      attr_reader :code

      def initialize(filename)
        @config_manager = MetaCL::Logic::ConfigManager.new
        @finalize = []
        super() # call initializers from modules
        @code = ""
        instance_eval IO.read(filename), filename
        @finalize.each(&:call)
        @code = Utils.apply_template 'wrapper', @config_manager.lang, code: Utils.tab_text(@code)
      end

      def configure(&block)
        MetaCL::DSL::Configure.new(@config_manager, &block)
      end

      def print_s(string)
        @code << "printf(\"#{string.gsub '"', '\"'}\\n\");\n"
      end

      include MetaCL::DSL::Matrix
    end
  end
end