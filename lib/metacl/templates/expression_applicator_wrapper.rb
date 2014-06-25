module MetaCL
  module Templates
    class ExpressionApplicatorWrapper < Mustache
      attr_reader :n_from, :n_to, :m_from, :m_to, :code
      attr_reader :kernel_code, :push_buffers, :template_params, :kernel_params, :pop_buffer

      def render(from_border, to_border, code, objects, result_object, platform)
        @n_from, @m_from  = from_border
        @n_to, @m_to      = to_border
        @code             = Utils.tab_text(code, platform == :cl ? 1 : 2)
        @objects          = objects
        @result_object    = result_object

        if platform == :cl
          gen_push_buffers
          gen_template_params
          gen_kernel_params
          gen_pop_buffer
          gen_kernel_code
        end

        super IO.read("#{__dir__}/expression_applicator_wrapper.#{platform}.template")
      end

      def gen_push_buffers
        @push_buffers = ""
        @objects.each do |x|
          case x.klass
            when :matrix
              @push_buffers << "queue.enqueueWriteBuffer(buffer_#{x.name},CL_TRUE,0,sizeof(#{x.type})*#{x.size_n}*#{x.size_m},#{x.name}.data());\n"
            when :array
              @push_buffers << "queue.enqueueWriteBuffer(buffer_#{x.name},CL_TRUE,0,sizeof(#{x.type})*#{x.length},#{x.name}.data());\n"
            when :numeric
              # TODO: @push_buffers << "queue.enqueueWriteBuffer(buffer_#{x.name},CL_TRUE,0,sizeof(#{x.type}),#{x.name};\n"
          end
        end
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

      def gen_pop_buffer
        x = @result_object
        @pop_buffer = "queue.enqueueReadBuffer(buffer_#{x.name},CL_TRUE,0,sizeof(#{x.type})*#{x.size_n}*#{x.size_m},#{x.name}.data());\n"
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

        @kernel_code = Templates::Kernel.render(params.join(', '), @code, @n_from, @m_from)
        @kernel_code = Utils.stringify_text(@kernel_code)
      end
    end
  end
end