# frozen_string_literal: true

module Reports
  module Pdf
    class PaymentReceiptReport < BillingDocument
      def initialize(receipt, settings: Setting.instance)
        super(receipt, settings: settings, copy_type: nil)
        @receipt = receipt
        @sale = receipt.sale
      end

      private

      def render_body(pdf)
        render_dealer_header(
          pdf,
          "Payment Receipt / Voucher",
          folio: [
            [ "Receipt No.", @receipt.receipt_number ],
            [ "Date", format_date(@receipt.received_on) ],
            [ "Head", @receipt.display_head ],
            [ "Mode", @receipt.display_payment_mode ]
          ]
        )

        pdf.table(
          [
            [ "Receipt No.", @receipt.receipt_number, "Date", format_date(@receipt.received_on) ],
            [ "Head", @receipt.display_head, "Mode", @receipt.display_payment_mode ],
            [ "Reference", @receipt.reference_no.presence || "-", "Against sale", "Sale ##{@sale.id}" ]
          ],
          width: pdf.bounds.width,
          cell_style: { size: 9, padding: [ 4, 6, 4, 6 ] }
        ) do
          columns([ 0, 2 ]).font_style = :bold
        end
        pdf.move_down 14

        pdf.text "Received from", size: 11, style: :bold
        pdf.text @sale.customer_name, size: 12
        pdf.text "Phone: #{@sale.phone}", size: 9
        pdf.move_down 10

        pdf.text "Towards", size: 11, style: :bold
        pdf.text "#{@sale.bike.name}  |  Sale ##{@sale.id}", size: 10
        pdf.text "Chassis: #{@sale.chassis_number.presence || 'Not allotted yet'}", size: 9, color: MUTED
        pdf.move_down 12

        pdf.table(
          [
            [ "Amount received", money(@receipt.amount) ],
            [ "Total on-road", money(@sale.total_price) ],
            [ "Total received till date", money(@sale.amount_received) ],
            [ "Outstanding", money(@sale.outstanding_amount) ]
          ],
          width: pdf.bounds.width * 0.55,
          cell_style: { size: 9, padding: [ 4, 6, 4, 6 ] }
        ) do
          row(0).font_style = :bold
          columns(1).align = :right
        end
        pdf.move_down 8
        pdf.text "Amount in words: #{Billing::AmountInWords.rupees(@receipt.amount)}", size: 9, style: :italic
        if @receipt.notes.present?
          pdf.move_down 10
          pdf.text "Notes: #{@receipt.notes}", size: 9
        end
        pdf.move_down 12
        pdf.text "Received by: #{@receipt.received_by&.name || '—'}", size: 9
        render_authorized_signatory(pdf)
      end
    end
  end
end
