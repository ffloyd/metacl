require 'erb'
require 'ostruct'

class MetaCL::DSL
  attr_reader :lang

  def initialize(lang, &block)
    @lang = lang
    @code = ""
    instance_eval &block if block_given?
  end

  # dsl methods
  def print_s(string)
    @code << "printf(\"#{string.gsub '"', '\"'}\\n\");"
  end
  # dsl methods ends

  def generate_binding(data = {})
    OpenStruct.new(data).instance_eval { binding }
  end

  def wrapped_code
    tabbed_code = @code.split("\n").map { |s| "    #{s}" }.join("\n")
    ERB.new(read_wrapper_template).result(generate_binding(code: tabbed_code))
  end

  def result
    @wrapped_code ||= wrapped_code
  end

  def unwrapped_result
    @code
  end

  def read_wrapper_template
    File.read File.dirname(__FILE__) + "/templates/wrappers/#{@lang}_wrapper.c.erb"
  end
end