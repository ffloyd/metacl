module MetaCL
  module Templates
    class UploadToGPU < Mustache

      def render(object, platform)
        if platform == :cl
          case object.klass
            when :matrix
              @result = "queue.enqueueWriteBuffer(buffer_#{object.name},CL_TRUE,0,sizeof(#{object.type})*#{object.size_n}*#{object.size_m},#{object.name}.data());\n"
            when :array
              @result = "queue.enqueueWriteBuffer(buffer_#{object.name},CL_TRUE,0,sizeof(#{object.type})*#{object.length},#{object.name}.data());\n"
            when :numeric
              # TODO: @push_buffers << "queue.enqueueWriteBuffer(buffer_#{x.name},CL_TRUE,0,sizeof(#{x.type}),#{x.name};\n"
          end
        end
        @result || ''
      end
    end
  end
end