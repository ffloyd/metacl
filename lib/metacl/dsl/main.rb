module MetaCL
  module DSL
    using SymbolRefinement

    class Main
      include Matrix

      attr_reader :code

      def initialize(filename)
        @config_manager = Logic::ConfigManager.new
        @var_manager    = Logic::VarManager.new(@config_manager)
        @finalize = []
        super() # call initializers from modules
        @code = ""
        instance_eval IO.read(filename), filename
        @finalize.each(&:call)
        @code = Utils.apply_template 'wrapper', @config_manager.lang, code: Utils.tab_text(@code)
      end

      def configure(&block)
        Configure.new(@config_manager, &block)
      end

      def print_s(string)
        @code << "printf(\"#{string.gsub '"', '\"'}\\n\");\n"
      end

      def direct(string)
        @code << string << "\n"
      end

      def define_var(name, type, opts = {})
        @var_manager.add_var name, type
        unless opts[:nocode]
          @code << Utils.apply_template('define_var', @config_manager.lang, name: name, type: type, assign: opts[:assign]) << "\n"
        end
      end
    end
  end
end