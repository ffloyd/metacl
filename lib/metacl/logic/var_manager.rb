module MetaCL
  module Logic
    Var = Struct.new :name, :type

    class VarManager
      def initialize(config_manager)
        @vars   = {}
        @config = config_manager
      end

      def add_var(name, type)
        raise Error::VarNameDuplication    if @vars.has_key? name
        raise Error::VarUnknownElementType unless @config.allowed_types.include? type

        @vars[:name] = Var.new name, type

        self
      end

      def [](name)
        check_var_names name
        @vars[name]
      end

      def check_var_names(names)
        (names.is_a?(Array) ? names : [names]).each do |name|
          raise Error::VarNotFound unless @vars.has_key? name
        end
      end
    end
  end
end