module MetaCL
  module Templates
    class ExpressionApplicatorWrapper < Mustache
      attr_reader :n_from, :n_to, :m_from, :m_to, :code

      def render(from_border, to_border, code, platform)
        @n_from, @m_from  = from_border
        @n_to, @m_to      = to_border
        @code             = Utils.tab_text(code, 2)

        super IO.read("#{__dir__}/expression_applicator_wrapper.#{platform}.template")
      end
    end
  end
end