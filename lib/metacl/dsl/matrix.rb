require 'metacl/utils'
require 'metacl/logic/matrix_manager'

module MetaCL
  module DSL
    module Matrix
      def initialize
        @matrix_manager = MetaCL::Logic::MatrixManager.new(@config_manager)
      end

      def create_matrix(name, type, n, m)
        @matrix_manager.add_matrix(name, type, n, m)
        @code << MetaCL::Utils.apply_template('create_matrix', @config_manager.lang, name: name, type: type, n: n, m: m) << "\n"
      end
    end
  end
end