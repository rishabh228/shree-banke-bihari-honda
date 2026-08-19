# frozen_string_literal: true

module Admin
  class ReportsController < BaseController
    def index
      authorize :report, :index?

      @from = parse_date(params[:from], Date.current.beginning_of_month)
      @to = parse_date(params[:to], Date.current)
      @charts = Dashboard::ChartsService.call
      @stats = Dashboard::StatsService.call
      @register = Reports::DealerRegisterService.new(from: @from, to: @to)
    end

    def tally_export
      authorize :report, :tally_export?

      export = Billing::TallyExportService.new(
        from: parse_date(params[:from], Date.current.beginning_of_month),
        to: parse_date(params[:to], Date.current)
      )

      if params[:kind].to_s == "xml"
        send_data export.to_xml,
                  filename: export.xml_filename,
                  type: "application/xml",
                  disposition: "attachment"
      else
        send_data export.to_csv,
                  filename: export.filename,
                  type: "text/csv",
                  disposition: "attachment"
      end
    end

    private

    def parse_date(value, fallback)
      return fallback if value.blank?

      Date.parse(value.to_s)
    rescue ArgumentError
      fallback
    end
  end
end
