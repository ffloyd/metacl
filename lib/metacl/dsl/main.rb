require 'metacl/utils'
require 'metacl/dsl/configure'
require 'metacl/logic/config_manager'
require 'metacl/dsl/matrix'

module MetaCL
  module DSL
    class Main
      attr_reader :code

      def initialize(&block)
        @config_manager = MetaCL::Logic::ConfigManager.new
        super # call initializers from modules
        @code = ""
        instance_eval &block if block_given?
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