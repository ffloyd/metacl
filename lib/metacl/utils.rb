module MetaCL
  class Utils
    class << self
      def tab_text(text, tabs = 1, tab_size = 4)
        text.split("\n").map{ |s| ' '*tab_size*tabs + s }.join("\n")
      end

      def stringify_text(text)
        text.split("\n").map{ |s| '"' + s.gsub('"', '""') + '\\n"' }.tap { |t|
          t[-1] = t[-1] + ";"
        }.join("\n")
      end
    end
  end
end