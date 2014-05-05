module MetaCL
  module DSL
    module Matrix
      def initialize
        @matrix_manager = Logic::MatrixManager.new(@config_manager)
        @finalize << Proc.new { destroy_all_matrices }
      end

      def create_matrix(name, type, n, m, options = {})
        @matrix_manager.add_matrix(name, type, n, m)
        params = {
            name: name,
            type: type,
            n: n,
            m: m,
            fill_with: options[:fill_with]
        }
        @code << Utils.apply_template('create_matrix', @config_manager.lang, params) << "\n"
      end

      def destroy_matrix(name)
        @matrix_manager.delete_matrix(name)
        @code << Utils.apply_template('destroy_matrix', @config_manager.lang, name: name) << "\n"
      end

      def destroy_all_matrices
        @matrix_manager.matrix_names.each do |name|
          destroy_matrix name
        end
      end

      def calculate_matrix(name, opts = {}, &block)
        expression = MatrixExpression.new(@matrix_manager, @config_manager, name, opts, &block)
        code << expression.code << "\n"
      end

      def print_matrix(name)
        matrix = @matrix_manager[name]
        code << Utils.apply_template('print_matrix', @config_manager.lang, name: name, n: matrix.n, m: matrix.m) << "\n"
      end
    end
  end
end