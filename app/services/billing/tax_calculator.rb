# frozen_string_literal: true

module Billing
  class TaxCalculator
    def initialize(sale, settings: Setting.instance)
      @sale = sale
      @settings = settings
    end

    def result
      lines = build_lines
      taxable_lines = lines.reject { |line| line[:collected] }
      collected_lines = lines.select { |line| line[:collected] }

      taxable_total = taxable_lines.sum { |line| line[:taxable_value] }
      tax_total = taxable_lines.sum { |line| line[:cgst_amount] + line[:sgst_amount] + line[:igst_amount] }
      collected_total = collected_lines.sum { |line| line[:inclusive_amount] }
      grand_total = taxable_lines.sum { |line| line[:inclusive_amount] } + collected_total

      vehicle = taxable_lines.find { |line| line[:line_type] == "vehicle" } || empty_gst_line
      handling = taxable_lines.find { |line| line[:line_type] == "handling" }
      accessories = taxable_lines.select { |line| line[:line_type] == "accessory" }
      accessory_totals = sum_lines(accessories)
      insurance = collected_lines.find { |line| line[:line_type] == "insurance" }
      rto = collected_lines.find { |line| line[:line_type] == "rto" }

      {
        inter_state: inter_state?,
        reverse_charge: false,
        place_of_supply: place_of_supply,
        place_of_supply_code: place_of_supply_code,
        hsn_code: @sale.bike.hsn,
        accessories_hsn: @settings.accessories_hsn_code,
        vehicle_gst_rate: vehicle_rate,
        accessories_gst_rate: accessories_rate,
        vehicle_inclusive: vehicle[:inclusive_amount],
        vehicle_taxable: vehicle[:taxable_value],
        vehicle_cgst: vehicle[:cgst_amount],
        vehicle_sgst: vehicle[:sgst_amount],
        vehicle_igst: vehicle[:igst_amount],
        accessories_inclusive: accessory_totals[:inclusive] + (handling ? handling[:inclusive_amount] : 0),
        accessories_taxable: accessory_totals[:taxable] + (handling ? handling[:taxable_value] : 0),
        accessories_cgst: accessory_totals[:cgst] + (handling ? handling[:cgst_amount] : 0),
        accessories_sgst: accessory_totals[:sgst] + (handling ? handling[:sgst_amount] : 0),
        accessories_igst: accessory_totals[:igst] + (handling ? handling[:igst_amount] : 0),
        insurance_collected: insurance ? insurance[:inclusive_amount] : 0.to_d,
        rto_collected: rto ? rto[:inclusive_amount] : 0.to_d,
        discount_value: @sale.discount_value,
        discount_percent: @sale.discount_percent.to_d,
        taxable_total: taxable_total.round(2),
        tax_total: tax_total.round(2),
        grand_total: grand_total.round(2),
        lines: lines,
        hsn_summary: hsn_summary(taxable_lines)
      }
    end

    def breakdown
      result
    end

    private

    def build_lines
      position = 0
      lines = []

      lines << gst_line(
        line_type: "vehicle",
        description: vehicle_description,
        hsn_code: @sale.bike.hsn,
        quantity: 1,
        inclusive: @sale.vehicle_inclusive_after_discount,
        rate: vehicle_rate,
        position: position += 1
      )

      if @sale.handling_charge.to_d.positive?
        lines << gst_line(
          line_type: "handling",
          description: "Handling / documentation charges",
          hsn_code: @settings.handling_hsn_code,
          quantity: 1,
          inclusive: @sale.handling_charge,
          rate: @settings.handling_tax_rate,
          position: position += 1
        )
      end

      if @sale.accessories_charge.to_d.positive?
        lines << gst_line(
          line_type: "accessory",
          description: "OEM accessories pack",
          hsn_code: @settings.accessories_hsn_code,
          quantity: 1,
          inclusive: @sale.accessories_charge,
          rate: accessories_rate,
          position: position += 1
        )
      end

      @sale.sale_add_ons.each do |add_on|
        next unless add_on.line_total.positive?

        lines << gst_line(
          line_type: "accessory",
          description: add_on.description,
          hsn_code: add_on.hsn_code.presence || @settings.accessories_hsn_code,
          quantity: add_on.quantity,
          inclusive: add_on.line_total,
          rate: (add_on.gst_rate.presence || accessories_rate).to_d,
          position: position += 1
        )
      end

      if @sale.insurance.to_d.positive?
        lines << collected_line("insurance", "Insurance (collected for insurer)", @sale.insurance, position += 1)
      end

      if @sale.rto.to_d.positive?
        lines << collected_line("rto", "RTO / registration (collected for RTO)", @sale.rto, position += 1)
      end

      lines
    end

    def gst_line(line_type:, description:, hsn_code:, quantity:, inclusive:, rate:, position:)
      split = InclusiveTax.split(inclusive, rate)
      gst = InclusiveTax.allocate_gst(split[:tax], inter_state: inter_state?)
      half_rate = inter_state? ? 0.to_d : (rate / 2).round(2)

      {
        position: position,
        line_type: line_type,
        description: description,
        hsn_code: hsn_code,
        quantity: quantity.to_d,
        uqc: "NOS",
        gst_rate: rate,
        taxable_value: split[:taxable],
        cgst_rate: inter_state? ? 0.to_d : half_rate,
        sgst_rate: inter_state? ? 0.to_d : (rate - half_rate).round(2),
        igst_rate: inter_state? ? rate : 0.to_d,
        cgst_amount: gst[:cgst],
        sgst_amount: gst[:sgst],
        igst_amount: gst[:igst],
        inclusive_amount: split[:inclusive],
        collected: false
      }
    end

    def collected_line(line_type, description, amount, position)
      {
        position: position,
        line_type: line_type,
        description: description,
        hsn_code: nil,
        quantity: 1.to_d,
        uqc: "NOS",
        gst_rate: 0.to_d,
        taxable_value: 0.to_d,
        cgst_rate: 0.to_d,
        sgst_rate: 0.to_d,
        igst_rate: 0.to_d,
        cgst_amount: 0.to_d,
        sgst_amount: 0.to_d,
        igst_amount: 0.to_d,
        inclusive_amount: amount.to_d.round(2),
        collected: true
      }
    end

    def hsn_summary(lines)
      lines.group_by { |line| [ line[:hsn_code], line[:gst_rate] ] }.map do |(hsn, rate), grouped|
        {
          hsn_code: hsn,
          gst_rate: rate,
          taxable_value: grouped.sum { |line| line[:taxable_value] }.round(2),
          cgst_amount: grouped.sum { |line| line[:cgst_amount] }.round(2),
          sgst_amount: grouped.sum { |line| line[:sgst_amount] }.round(2),
          igst_amount: grouped.sum { |line| line[:igst_amount] }.round(2)
        }
      end
    end

    def sum_lines(lines)
      {
        inclusive: lines.sum { |line| line[:inclusive_amount] },
        taxable: lines.sum { |line| line[:taxable_value] },
        cgst: lines.sum { |line| line[:cgst_amount] },
        sgst: lines.sum { |line| line[:sgst_amount] },
        igst: lines.sum { |line| line[:igst_amount] }
      }
    end

    def empty_gst_line
      {
        inclusive_amount: 0.to_d, taxable_value: 0.to_d,
        cgst_amount: 0.to_d, sgst_amount: 0.to_d, igst_amount: 0.to_d
      }
    end

    def vehicle_description
      bike = @sale.bike
      lines = [ "Honda #{bike.name} (GST inclusive)" ]
      if @sale.discount_value.positive?
        lines << "Less dealer discount: INR #{format('%.2f', @sale.discount_value)}"
        lines << "Discount #{@sale.discount_percent.to_d}% on ex-showroom" if @sale.discount_percent.to_d.positive?
      end
      lines << "Variant / colour: #{[ @sale.bike_variant&.name, @sale.bike_variant&.color ].compact.join(' / ')}" if @sale.bike_variant.present?
      lines << "Engine: #{bike.engine}" if bike.engine.present?
      bike.bike_specifications.limit(6).each do |spec|
        next if spec.label.blank? || spec.value.blank?

        lines << "#{spec.label}: #{spec.value}"
      end
      lines.join("\n")
    end

    def vehicle_rate
      @sale.bike.tax_rate
    end

    def accessories_rate
      @settings.accessories_tax_rate
    end

    def inter_state?
      buyer = @sale.buyer_state.to_s.strip.downcase
      dealer = @settings.state.to_s.strip.downcase
      buyer.present? && dealer.present? && buyer != dealer
    end

    def place_of_supply
      @sale.buyer_state.presence || @settings.state.presence || "—"
    end

    def place_of_supply_code
      @sale.buyer_state_code.presence || @settings.state_code.presence
    end
  end
end
