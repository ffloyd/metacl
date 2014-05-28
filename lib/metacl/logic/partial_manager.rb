module MetaCL
  module Logic
    Partial = Struct.new :name, :params, :tree do
      def get_tree_with_substitution(subst)
        new_tree = tree.deep_clone
        new_tree.leaves.each do
          |leaf| leaf.name = subst[leaf.name]
        end
        new_tree
      end
    end

    class PartialManager
      def initialize(config_manager)
        @partials   = {}
        @config = config_manager
      end

      def add_partial(name, params, tree)
        raise Error::PartialNameDuplication if @partials.has_key? name

        @partials[name] = Partial.new name, params, tree

        self
      end

      def [](name)
        check_partial_names name
        @partials[name]
      end

      def check_partial_names(names)
        (names.is_a?(Array) ? names : [names]).each do |name|
          raise Error::PartialNotFound unless @partials.has_key? name
        end
      end
    end
  end
end