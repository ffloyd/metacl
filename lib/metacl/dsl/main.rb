require 'metacl/utils'
require 'metacl/dsl/configure'
require 'metacl/dsl/matrix'

module MetaCL
  module DSL
    class Main
      attr_reader :code

      def initialize(&block)
        super # call initializers from modules
        @code = ""
        instance_eval &block if block_given?
        @code = Utils.apply_template 'wrapper', @lang, code: Utils.tab_text(@code)
      end

      def configure(&block)
        @config = Configure.new(&block).config
        @lang   = @config[:lang]
      end

      def print_s(string)
        @code << "printf(\"#{string.gsub '"', '\"'}\\n\");\n"
      end

      include MetaCL::DSL::Matrix
    end
  end
end