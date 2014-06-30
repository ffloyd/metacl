module MetaCL
  module Templates
    class DownloadFromGPU < Mustache

      def render(object, platform)
        if platform == :cl
          "queue.enqueueReadBuffer(buffer_#{object.name},CL_TRUE,0,sizeof(#{object.type})*#{object.size_n}*#{object.size_m},#{object.name}.data());\n"
        else
          ""
        end
      end
    end
  end
end