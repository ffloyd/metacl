module MetaCL
  module Logic
    class IndexArg
      attr_reader :symbol, :offset, :rpart, :rsign

      def initialize(symbol)
        @symbol = symbol
        @offset = 0
        @rsign  = nil
        @rpart  = nil
      end

      def +(smth)
        self.clone.apply_operation! :+, smth
      end

      def -(smth)
        self.clone.apply_operation! :-, smth
      end

      def /(smth)
        self.clone.apply_operation! :/, smth
      end

      def *(smth)
        self.clone.apply_operation! :*, smth
      end

      def gen_string(n_iterator, m_iterator)
        result =  if @symbol == :i
                    n_iterator
                  elsif @symbol == :j
                    m_iterator
                  end

        result += sgn(@offset).to_s + @offset.abs.to_s unless @offset.zero?
        result += @rsign.to_s + "(" + @rpart.gen_string(n_iterator, m_iterator) + ")" if @rpart

        result
      end

      def apply_operation!(op, arg)
        if arg.kind_of? Fixnum
          @offset = @offset.send op, arg
        elsif arg.kind_of? IndexArg
          @rsign = op
          @rpart = arg
        end
        self
      end

      private

      def sgn(fixnum)
        (fixnum < 0) ? :- : :+
      end
    end
  end
end
