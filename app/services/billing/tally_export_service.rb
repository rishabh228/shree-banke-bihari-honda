# frozen_string_literal: true

require "csv"
require "builder"

module Billing
  class TallyExportService
    HEADERS = [
      "Date", "Voucher Type", "Voucher No", "Party Name", "GSTIN", "Place of Supply",
      "Taxable Value", "CGST", "SGST", "IGST", "Invoice Value", "IRN", "Narration"
    ].freeze

    def initialize(from:, to:, settings: Setting.instance)
      @from = from.presence || Date.current.beginning_of_month
      @to = to.presence || Date.current
      @settings = settings
    end

    def filename
      "tally-vouchers-#{@from}-to-#{@to}.csv"
    end

    def xml_filename
      "tally-vouchers-#{@from}-to-#{@to}.xml"
    end

    def to_csv
      CSV.generate(headers: true) do |csv|
        csv << HEADERS
        vouchers.each { |voucher| csv << csv_row(voucher) }
      end
    end

    def to_xml
      xml = Builder::XmlMarkup.new(indent: 2)
      xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
      xml.ENVELOPE do
        xml.HEADER { xml.TALLYREQUEST "Import Data" }
        xml.BODY do
          xml.IMPORTDATA do
            xml.REQUESTDESC do
              xml.REPORTNAME "Vouchers"
              xml.STATICVARIABLES { xml.SVCURRENTCOMPANY company_name }
            end
            xml.REQUESTDATA do
              vouchers.each do |voucher|
                xml.TALLYMESSAGE("xmlns:UDF" => "TallyUDF") do
                  render_voucher(xml, voucher)
                end
              end
            end
          end
        end
      end
      xml.target!
    end

    def vouchers
      vehicle_vouchers + counter_vouchers + credit_note_vouchers + receipt_vouchers
    end

    private

    def csv_row(voucher)
      [
        voucher[:date].strftime("%d-%m-%Y"),
        voucher[:type],
        voucher[:number],
        voucher[:party],
        voucher[:gstin],
        voucher[:place_of_supply],
        format_amt(voucher[:taxable]),
        format_amt(voucher[:cgst]),
        format_amt(voucher[:sgst]),
        format_amt(voucher[:igst]),
        format_amt(voucher[:value]),
        voucher[:irn],
        voucher[:narration]
      ]
    end

    def vehicle_vouchers
      Invoice.issued.includes(:sale, :line_items).where(invoice_date: @from..@to).order(:invoice_date, :id).map do |invoice|
        sale = invoice.sale
        split = vehicle_gst(invoice)
        {
          date: invoice.invoice_date,
          type: "Sales",
          number: invoice.invoice_number,
          party: sale.customer_name,
          gstin: sale.buyer_gstin,
          place_of_supply: [ invoice.place_of_supply, invoice.place_of_supply_code ].compact_blank.join(" / "),
          taxable: invoice.taxable_total.to_d,
          cgst: split[:cgst],
          sgst: split[:sgst],
          igst: split[:igst],
          value: invoice.grand_total.to_d,
          irn: invoice.irn,
          narration: "Vehicle tax invoice #{sale.bike.name}",
          collected: invoice.insurance_collected.to_d + invoice.rto_collected.to_d
        }
      end
    end

    def counter_vouchers
      CounterInvoice.issued.includes(:lines).where(invoice_date: @from..@to).order(:invoice_date, :id).map do |invoice|
        split = gst_split(invoice.lines)
        {
          date: invoice.invoice_date,
          type: "Sales",
          number: invoice.invoice_number,
          party: invoice.customer_name,
          gstin: invoice.buyer_gstin,
          place_of_supply: [ invoice.place_of_supply, invoice.place_of_supply_code ].compact_blank.join(" / "),
          taxable: invoice.taxable_total.to_d,
          cgst: split[:cgst],
          sgst: split[:sgst],
          igst: split[:igst],
          value: invoice.grand_total.to_d,
          irn: invoice.irn,
          narration: invoice.workshop? ? "Workshop job card invoice" : "Spare counter invoice",
          collected: 0.to_d
        }
      end
    end

    def credit_note_vouchers
      CreditNote.where(credit_note_date: @from..@to).includes(:invoice, :sale, :counter_invoice).order(:credit_note_date, :id).map do |note|
        split = note.gst_split
        {
          date: note.credit_note_date,
          type: "Credit Note",
          number: note.credit_note_number,
          party: note.party_name,
          gstin: note.party_gstin,
          place_of_supply: place_of_supply_for(note),
          taxable: -note.reversed_taxable.to_d,
          cgst: -split[:cgst],
          sgst: -split[:sgst],
          igst: -split[:igst],
          value: -note.grand_total.to_d,
          irn: nil,
          narration: "Against #{note.against_number}: #{note.reason}",
          collected: -note.reversed_collected.to_d
        }
      end
    end

    def receipt_vouchers
      PaymentReceipt.includes(:sale).where(received_on: @from..@to).order(:received_on, :id).map do |receipt|
        {
          date: receipt.received_on,
          type: "Receipt",
          number: receipt.receipt_number,
          party: receipt.sale.customer_name,
          gstin: receipt.sale.buyer_gstin,
          place_of_supply: receipt.sale.buyer_state,
          taxable: 0.to_d,
          cgst: 0.to_d,
          sgst: 0.to_d,
          igst: 0.to_d,
          value: receipt.amount.to_d,
          irn: nil,
          narration: "Receipt #{receipt.display_payment_mode} — #{receipt.sale.customer_name}",
          payment_mode: receipt.payment_mode.to_s,
          collected: 0.to_d
        }
      end
    end

    def render_voucher(xml, voucher)
      xml.VOUCHER("VCHTYPE" => voucher[:type], "ACTION" => "Create") do
        xml.DATE voucher[:date].strftime("%Y%m%d")
        xml.VOUCHERTYPENAME voucher[:type]
        xml.VOUCHERNUMBER voucher[:number]
        xml.REFERENCE voucher[:irn] if voucher[:irn].present?
        xml.PARTYLEDGERNAME voucher[:party]
        xml.BASICBASEPARTYNAME voucher[:party]
        xml.PARTYGSTIN voucher[:gstin] if voucher[:gstin].present?
        xml.PLACEOFSUPPLY voucher[:place_of_supply] if voucher[:place_of_supply].present?
        xml.NARRATION voucher[:narration]
        xml.ISINVOICE(voucher[:type] == "Receipt" ? "No" : "Yes")
        render_ledger_lines(xml, voucher)
      end
    end

    def render_ledger_lines(xml, voucher)
      case voucher[:type]
      when "Receipt"
        cash_ledger = receipt_ledger_name(voucher[:payment_mode])
        ledger_entry(xml, voucher[:party], credit: voucher[:value])
        ledger_entry(xml, cash_ledger, debit: voucher[:value])
      when "Credit Note"
        ledger_entry(xml, voucher[:party], credit: voucher[:value].abs)
        ledger_entry(xml, "Sales", debit: voucher[:taxable].abs) if voucher[:taxable].to_d.abs.positive?
        ledger_entry(xml, "CGST", debit: voucher[:cgst].abs) if voucher[:cgst].to_d.abs.positive?
        ledger_entry(xml, "SGST", debit: voucher[:sgst].abs) if voucher[:sgst].to_d.abs.positive?
        ledger_entry(xml, "IGST", debit: voucher[:igst].abs) if voucher[:igst].to_d.abs.positive?
        ledger_entry(xml, "Insurance / RTO collected", debit: voucher[:collected].abs) if voucher[:collected].to_d.abs.positive?
      else
        ledger_entry(xml, voucher[:party], debit: voucher[:value])
        ledger_entry(xml, "Sales", credit: voucher[:taxable]) if voucher[:taxable].to_d.positive?
        ledger_entry(xml, "CGST", credit: voucher[:cgst]) if voucher[:cgst].to_d.positive?
        ledger_entry(xml, "SGST", credit: voucher[:sgst]) if voucher[:sgst].to_d.positive?
        ledger_entry(xml, "IGST", credit: voucher[:igst]) if voucher[:igst].to_d.positive?
        ledger_entry(xml, "Insurance / RTO collected", credit: voucher[:collected]) if voucher[:collected].to_d.positive?
      end
    end

    def ledger_entry(xml, name, debit: nil, credit: nil)
      amount = debit.present? ? -debit.to_d : credit.to_d
      xml.tag!("ALLLEDGERENTRIES.LIST") do
        xml.LEDGERNAME name
        xml.ISDEEMEDPOSITIVE(debit.present? ? "Yes" : "No")
        xml.AMOUNT format_amt(amount)
      end
    end

    def receipt_ledger_name(mode)
      case mode
      when "upi" then "UPI"
      when "finance" then "Finance / Bank"
      when "cheque" then "Cheque"
      when "bank_transfer" then "Bank"
      else "Cash"
      end
    end

    def company_name
      @settings.legal_showroom_name.presence || @settings.showroom_name
    end

    def place_of_supply_for(note)
      if note.invoice
        [ note.invoice.place_of_supply, note.invoice.place_of_supply_code ].compact_blank.join(" / ")
      elsif note.counter_invoice
        [ note.counter_invoice.place_of_supply, note.counter_invoice.place_of_supply_code ].compact_blank.join(" / ")
      end
    end

    def vehicle_gst(invoice)
      if invoice.line_items.any?
        gst_split(invoice.line_items)
      else
        {
          cgst: invoice.vehicle_cgst.to_d + invoice.accessories_cgst.to_d,
          sgst: invoice.vehicle_sgst.to_d + invoice.accessories_sgst.to_d,
          igst: invoice.vehicle_igst.to_d + invoice.accessories_igst.to_d
        }
      end
    end

    def gst_split(lines)
      loaded = lines.respond_to?(:to_a) ? lines.to_a : lines
      {
        cgst: loaded.sum { |line| line.cgst_amount.to_d },
        sgst: loaded.sum { |line| line.sgst_amount.to_d },
        igst: loaded.sum { |line| line.igst_amount.to_d }
      }
    end

    def format_amt(value)
      format("%.2f", value.to_d)
    end
  end
end
