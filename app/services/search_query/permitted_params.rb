# frozen_string_literal: true

module SearchQuery
  class PermittedParams
    PREDICATES = %w[eq not_eq cont not_cont start end gt lt gteq lteq present blank in].freeze

    def self.call(model_class, raw_query)
      return {} unless raw_query.is_a?(ActionController::Parameters)

      raw_query.permit(*build_keys(model_class))
    end

    def self.build_keys(model_class)
      attribute_keys = model_class.ransackable_attributes.flat_map do |attribute|
        PREDICATES.map { |predicate| "#{attribute}_#{predicate}" }
      end

      association_keys = model_class.ransackable_associations.flat_map do |association|
        [ "#{association}_id_eq", "#{association}_eq" ]
      end

      (attribute_keys + association_keys).uniq
    end
  end
end
