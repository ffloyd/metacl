module MetaCL
  module Templates
    class KernelInit < Mustache
      attr_reader :counter, :kernel_code, :n_from, :m_from, :n_to, :m_to, :template_params

      def render(from_border, to_border, code, result_object, objects, counter, platform)
        if platform == :cl
          @counter        = counter
          @code           = Utils.tab_text(code, 1)
          @result_object  = result_object
          @objects        = objects
          @n_from, @m_from  = from_border
          @n_to, @m_to      = to_border
          gen_kernel_code
          gen_template_params
          super IO.read("#{__dir__}/kernel_init.cl.template")
        end
      end

      def gen_kernel_code
        params = []
        @objects.each do |x|
          case x.klass
            when :matrix, :array
              params << "global const #{x.type}* #{x.name}"
            when :numeric
              # TODO
          end
        end
        params << "global #{@result_object.type}* #{@result_object.name}"

        @kernel_code = Templates::Kernel.render(params.join(', '), @code, @n_from, @m_from, @counter)
        @kernel_code = Utils.stringify_text(@kernel_code)
      end

      def gen_template_params
        params = []
        @objects.each do |x|
          case x.klass
            when :matrix, :array
              params << "cl::Buffer&"
            when :numeric
              # TODO
          end
        end
        params << "cl::Buffer&" # for result
        @template_params = params.join(', ')
      end
    end
  end
end
