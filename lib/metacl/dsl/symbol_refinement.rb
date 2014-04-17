module MetaCL
  module DSL
    module SymbolRefinement
      refine Symbol do
        def +(arg)
          :it_works!
        end
      end
    end
  end
end