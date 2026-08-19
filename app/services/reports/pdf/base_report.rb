# frozen_string_literal: true

require "prawn"
require "prawn/table"

module Reports
  module Pdf
    class BaseReport
      HONDA_RED = "CC0000"
      HEADER_BG = "1A1A1A"

      def initialize(records, settings: Setting.instance)
        @records = records
        @settings = settings
      end

      def render
        Prawn::Document.new(page_size: "A4", page_layout: page_layout, margin: 36) do |pdf|
          render_header(pdf)
          render_table(pdf)
          render_footer(pdf)
        end.render
      end

      private

      def page_layout
        :landscape
      end

      def report_title
        raise NotImplementedError
      end

      def table_headers
        raise NotImplementedError
      end

      def table_rows
        raise NotImplementedError
      end

      def render_header(pdf)
        pdf.text @settings.showroom_name, size: 16, style: :bold, color: HONDA_RED
        pdf.text report_title, size: 12, style: :bold
        pdf.fill_color "666666"
        pdf.text "Generated on #{Time.current.strftime('%d %b %Y at %I:%M %p')}  |  Total records: #{@records.size}",
                 size: 9
        pdf.fill_color "000000"
        pdf.move_down 16
      end

      def render_table(pdf)
        rows = [ table_headers ] + table_rows

        if rows.size <= 1
          pdf.text "No records found for the selected filters.", style: :italic
          return
        end

        pdf.table(rows, header: true, width: pdf.bounds.width, cell_style: { size: 8, padding: [ 4, 6, 4, 6 ] }) do
          row(0).font_style = :bold
          row(0).background_color = HEADER_BG
          row(0).text_color = "FFFFFF"
          columns(0).align = :left
        end
      end

      def render_footer(pdf)
        pdf.number_pages "Page <page> of <total>  |  #{@settings.showroom_name}",
                         at: [ pdf.bounds.left, 0 ],
                         align: :center,
                         size: 8,
                         color: "888888"
      end

      def format_date(date)
        return "—" if date.blank?

        date.strftime("%d %b %Y")
      end

      def format_datetime(datetime)
        return "—" if datetime.blank?

        datetime.strftime("%d %b %Y %I:%M %p")
      end

      def format_currency(amount)
        return "—" if amount.blank?

        "Rs. #{amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
      end

      def humanize_status(status)
        status.to_s.humanize.titleize
      end

      def truncate_text(text, length = 60)
        return "—" if text.blank?

        text.length > length ? "#{text[0...length]}..." : text
      end
    end
  end
end
