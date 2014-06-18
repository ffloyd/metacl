module MetaCL
  module Templates
    class Aggregator < Mustache
      attr_reader :type, :var, :iterator, :from, :to, :subresult_var, :operator, :code

      def render(platform, options = {})
        @type, @var, @iterator, @from, @to, @subresult_var, @operator, @code = options.values_at(:type, :var, :iterator, :from, :to, :subresult_var, :operator, :code)
        @code = Utils.tab_text(@code)
        super IO.read("#{__dir__}/aggregator.#{platform}.template")
      end
    end
  end
end