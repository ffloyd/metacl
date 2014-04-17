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
        raise Error::MatrixInvalidSizeParams  if n <= 0 or m <= 0

        @matrices[name] = Matrix.new(name, type, n, m)

        self
      end

      def delete_matrix(name)
        raise Error::MatrixNotFound unless @matrices.has_key? name
        @matrices.delete(name)

        self
      end

      def matrix_names
        @matrices.keys
      end

      def check_matrix(name)
        raise Error::MatrixNotFound unless @matrices.has_key? name
      end
    end
  end
end