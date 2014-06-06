module MetaCL
  module Logic
    Matrix = Struct.new :name, :type, :n, :m

    #noinspection ALL
    class MatrixManager
      def initialize(config_manager)
        @matrices = {}
        @config   = config_manager
      end

      def add_matrix(name, type, n, m)
        raise Error::MatrixNameDuplication    if @matrices.has_key? name
        raise Error::MatrixUnknownElementType unless @config.allowed_types.include? type
        raise Error::MatrixInvalidSizeParams  if n.is_a? Fixnum and n <= 0
        raise Error::MatrixInvalidSizeParams  if m.is_a? Fixnum and m <= 0

        @matrices[name] = Matrix.new(name, type, n, m)

        self
      end

      def [](name)
        check_matrix_names name
        @matrices[name]
      end

      def delete_matrix(name)
        raise Error::MatrixNotFound unless @matrices.has_key? name
        @matrices.delete(name)

        self
      end

      def matrix_names
        @matrices.keys
      end

      def check_matrix_names(names)
        (names.is_a?(Array) ? names : [names]).each do |name|
          unless name.kind_of? Numeric
            raise Error::MatrixNotFound unless @matrices.has_key? name
          end
        end
      end
    end
  end
end