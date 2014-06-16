module MetaCL
  class Program
    attr_accessor :code, :platform

    def initialize(filename)
      @code     = DSL::Root.new(self, filename).code
      @platform = :cpp
    end

    def set_platform(platform)
      @platform = platform
    end

    def self.create(filename)
      Program.new(filename).code
    end
  end
end