require 'metacl/utils'
require 'metacl/dsl/configure'

module MetaCL
  module DSL
    class Main
      attr_reader :code

      def initialize(&block)
        @code = ""
        instance_eval &block if block_given?
        @code = Utils.apply_template 'wrapper', @config[:lang], code: Utils.tab_text(@code)
      end

      def configure(&block)
        @config = Configure.new(&block).config
      end

      def print_s(string)
        @code << "printf(\"#{string.gsub '"', '\"'}\\n\");\n"
      end
    end
  end
end