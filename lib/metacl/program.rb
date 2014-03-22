require 'metacl/dsl/main'

module MetaCL
  module Program
    def create(&block)
      MetaCL::DSL::Main.new(&block).code
    end
    module_function :create
  end
end