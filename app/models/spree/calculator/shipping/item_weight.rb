module Spree
  module Calculator::Shipping
    class ItemWeight < SimpleWeight
      preference :costs_string, :text, default: "25:7\n50:15\n100:25\n9999:45"

      def self.description
        Spree.t(:item_weight)
      end

      def compute_package(package)
        content_items = package.contents
        line_items_total = total(content_items)
        handling_fee = preferred_handling_max > line_items_total ? preferred_handling_fee : 0.0
        costs = costs_string_to_hash(clean_costs_string)
        shipping_costs = 0.0

        content_items.each do |item|
          item_weight = item.variant.calculator_weight > 0.0 ? item.variant.calculator_weight : preferred_default_weight
          weight_class = costs.keys.select { |w| item_weight <= w }.min
          shipping_costs += costs[weight_class] * item.quantity
        end

        shipping_costs + handling_fee
      end
    end
  end
end