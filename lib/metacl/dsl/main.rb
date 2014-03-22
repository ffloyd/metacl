require 'metacl/utils'
require 'metacl/dsl/configure'

module MetaCL
  module DSL
    class Main
      attr_reader :code

      def initialize(&block)
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

      def create_matrix(name, type, n, m)
        @code << Utils.apply_template('create_matrix', @lang,
                                      name: name,
                                      type: type,
                                      n: n,
                                      m: m) << "\n"
      end

      def destroy_matrix(name)
        @code << Utils.apply_template('destroy_matrix', @lang, name: name) << "\n"
      end
    end
  end
end