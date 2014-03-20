require 'erb'
require 'ostruct'

class MetaCL::DSL
  attr_reader :code, :lang

  def initialize(lang, &block)
    @lang = lang
    @code = ""
    instance_eval &block if block_given?
    wrap_code!
  end

  def print_s(string)
    @code << "printf(\"#{string.gsub '"', '\"'}\");"
  end

  def wrap_code!
    @code = @code.split("\n").map { |s| "    #{s}" }.join("\n")
    correct_binding = OpenStruct.new(code: @code).instance_eval { binding }
    @code = ERB.new(read_wrapper_template).result(correct_binding)
  end

  def read_wrapper_template
    File.read File.dirname(__FILE__) + "/templates/wrappers/#{@lang}_wrapper.c.erb"
  end
end