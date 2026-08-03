# frozen_string_literal: true

module Admin
  module PdfExportable
    extend ActiveSupport::Concern

    private

    def export_pdf_scope(model_class, includes: [])
      scope = policy_scope(model_class).ransack(ransack_query_for(model_class)).result.order(created_at: :desc)
      includes.any? ? scope.includes(*includes) : scope
    end

    def send_pdf_report(report_class, records, filename_prefix)
      pdf = report_class.new(records).render

      send_data pdf,
                filename: "#{filename_prefix}-#{Date.current.iso8601}.pdf",
                type: "application/pdf",
                disposition: "attachment"
    end
  end
end
