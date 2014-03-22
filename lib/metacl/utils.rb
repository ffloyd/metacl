require 'erb'
require 'ostruct'

module MetaCL
  class Utils
    class << self
      # work with templates
      def apply_template(template_file, lang, data)
        ERB.new(read_template(template_file, lang)).result(generate_binding(data))
      end

      def generate_binding(data = {})
        OpenStruct.new(data).instance_eval { binding }
      end

      def read_template(template_file, lang)
        File.read File.dirname(__FILE__) + "/templates/#{template_file}.#{lang}.erb"
      end

      # text processing
      def tab_text(text, tabs = 1, tab_size = 4)
        text.split("\n").map{ |s| ' '*tab_size*tabs + s }.join("\n")
      end
    end
  end
end