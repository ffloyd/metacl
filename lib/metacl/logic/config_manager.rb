module MetaCL
  module Logic
    class ConfigManager
      def initialize
        @data = {
            allowed_types: [:int, :double, :float]
        }
      end

      def method_missing(meth, *args)
        if meth =~ /\A\w+\z/
          @data[meth]
        elsif meth =~ /\A\w+=\z/
          @data[meth[0..-2].to_sym] = args[0]
        end
      end
    end
  end
end