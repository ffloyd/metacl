module MetaCL
  class Program
    attr_accessor :code, :platform, :resources

    def initialize(filename)
      @platform   = :cpp
      @resources  = Logic::ResourceManager.new
      @code       = DSL::Root.new(self, filename).code
    end

    def set_platform(platform)
      @platform = platform
    end

    def self.create(filename)
      Program.new(filename).code
    end
  end
end