module MetaCL
  module DSL
    module Matrix
      ALLOWED_MATRIX_TYPES = %i[int float double]

      def initialize
        @matrices = {}
      end

      def create_matrix(name, type, n, m)
        name_sym, type_sym = name.to_sym, type.to_sym

        # check correctness
        unless ALLOWED_MATRIX_TYPES.include? type_sym
          raise "Incorrect matrix type '#{type}'. Allowed types is #{ALLOWED_MATRIX_TYPES.join(', ')}."
        end
        if @matrices.has_key? name_sym
          raise "You cannot create matrix with same name twice."
        end
        unless n.is_a?(Fixnum) and m.is_a?(Fixnum)
          raise "N and M must be integers."
        end

        @code << Utils.apply_template('create_matrix', @lang,
                                      name: name,
                                      type: type,
                                      n: n,
                                      m: m) << "\n"
        @matrices[name_sym] = MatrixObject.new(name_sym, type_sym, n, m)
      end

      def destroy_matrix(name)
        name_sym = name.to_sym
        raise "Cannot destroy nonexistent matrix with name '#{name_sym}'." unless @matrices.has_key? name_sym
        @code << Utils.apply_template('destroy_matrix', @lang, name: name) << "\n"
        @matrices.delete name_sym
      end
    end

    class MatrixObject
      attr_reader :name, :type, :n, :m

      def initialize(*args)
        @name, @type, @n, @m = *args
      end
    end
  end
end