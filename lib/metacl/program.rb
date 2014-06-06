module MetaCL
  module Program
    def create(filename)
      begin
        DSL::Main.new(filename).code
      # rescue Error::MetaCLError => error # TODO: filter backtrace output using filename
      #   top_eval_error_index = error.backtrace.find_index do |error|
      #     error =~ /dsl\/main(.+)instance_eval'\z/
      #   end
      #   puts error.backtrace[top_eval_error_index-1]
      #   puts error.message
      end
    end
    module_function :create
  end
end