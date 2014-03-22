module MetaCL
  module DSL
    class Configure
      attr_reader :config

      def initialize(&block)
        @config = {}
        instance_eval &block if block_given?
      end

      def lang(name)
        @config[:lang] = name.to_sym
      end
    end
  end
end