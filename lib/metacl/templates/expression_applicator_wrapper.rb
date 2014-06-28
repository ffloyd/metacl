module MetaCL
  module Templates
    class ExpressionApplicatorWrapper < Mustache
      attr_reader :n_from, :n_to, :m_from, :m_to, :code
      attr_reader :kernel_params, :counter

      def render(from_border, to_border, code, objects, result_object, counter, platform)
        @n_from, @m_from  = from_border
        @n_to, @m_to      = to_border
        @objects          = objects
        @result_object    = result_object
        @code             = Utils.tab_text(code, platform == :cl ? 1 : 2)
        @counter          = counter

        if platform == :cl
          gen_kernel_params
        end

        super IO.read("#{__dir__}/expression_applicator_wrapper.#{platform}.template")
      end

      def gen_kernel_params
        params = []
        @objects.each do |x|
          case x.klass
            when :matrix, :array
              params << "buffer_#{x.name}"
            when :numeric
              # TODO
          end
        end

        params << "buffer_#{@result_object.name}"
        @kernel_params = params.join(', ')
      end
    end
  end
end