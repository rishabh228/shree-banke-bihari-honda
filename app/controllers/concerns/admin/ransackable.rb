# frozen_string_literal: true

module Admin
  module Ransackable
    extend ActiveSupport::Concern

    private

    def ransack_query_for(model_class)
      ::SearchQuery::PermittedParams.call(model_class, params[:q])
    end
  end
end
