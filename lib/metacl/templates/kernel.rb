module MetaCL
  module Templates
    class Kernel < Mustache
      attr_reader :params, :code, :n_from, :m_from

      def render(params, code, n_from, m_from)
        @params, @code = params, code
        @n_from, @m_from = n_from, m_from
        super IO.read("#{__dir__}/kernel.cl.template")
      end
    end
  end
end