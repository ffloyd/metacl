module MetaCL
  module DSL
    module GPUTransfers
      def upload_to_gpu(*args)
        args.each do |name|
          object = @program.resources[name]
          @inner_code << Templates::UploadToGPU.render(object, @program.platform)
        end
        @inner_code  << "\n"
      end

      def download_from_gpu(*args)
        args.each do |name|
          object = @program.resources[name]
          @inner_code << Templates::DownloadFromGPU.render(object, @program.platform)
        end
        @inner_code  << "\n"
      end
    end
  end
end