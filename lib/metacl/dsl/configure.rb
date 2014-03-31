require 'metacl/logic/config_manager'

module MetaCL
  module DSL
    class Configure
      def initialize(manager, &block)
        @manager = manager
        instance_eval &block if block_given?
      end

      def allowed_types(*args)
        @manager.allowed_types.concat(args.flatten).uniq!
      end

      # should convert to symbols
      %i[lang].each do |name|
        define_method name do |value|
          @manager.send "#{name}=", value
        end
      end

    end
  end
end