module Spree
  module Calculator::Shipping
    class SimpleWeight < ShippingCalculator
      preference :costs_string, :text, default: "1:5\n2:7\n5:10\n10:15\n100:50"
      preference :default_weight, :decimal, default: 1
      preference :max_item_size, :decimal, default: 0
      preference :handling_fee, :decimal, default: 0
      preference :handling_max, :decimal, default: 0

      attr_accessible :preferred_costs_string,  :preferred_max_item_size,
                      :preferred_handling_max, :preferred_handling_fee,
                      :preferred_default_weight

      def self.description
        Spree.t(:simple_weight)
      end

      def self.register
        super
      end

      def available?(package)
        return false if !costs_string_valid? || order_overweight?(package.contents)

        if preferred_max_item_size > 0
          package.contents.each do |item|
            return false if item_oversized?(item)
          end
        end

        true
      end

      private
      def compute_package(package)
        content_items = package.contents
        line_items_total = total(content_items)
        handling_fee = preferred_handling_max > line_items_total ? preferred_handling_fee : 0

        total_weight = total_weight(content_items)
        costs = costs_string_to_hash(preferred_costs_string)
        weight_class = costs.keys.select { |w| total_weight <= w }.min
        shipping_costs = costs[weight_class]

        return 0 unless shipping_costs
        shipping_costs + handling_fee
      end

      def costs_string_valid?
        !preferred_costs_string.empty? &&
        preferred_costs_string.count(':') > 0 &&
        preferred_costs_string.split(/\:|\n/).size.even? &&
        preferred_costs_string.split(/\:|\n/).all? { |s | s.match(/^\d|\.+$/) }
      end

      def item_oversized?(item)
        return false if preferred_max_item_size == 0

        variant = item.variant
        sizes = [ variant.width || 0, variant.depth || 0, variant.height || 0 ]

        sizes.max > preferred_max_item_size
      end

      def order_overweight?(content_items)
        total_weight = total_weight(content_items)
        hash = costs_string_to_hash(preferred_costs_string)

        total_weight > hash.keys.max
      end

      def costs_string_to_hash(costs_string)
        costs = {}
        costs_string.split.each do |cost_string|
          values = cost_string.strip.split(':')
          costs[values[0].strip.to_f] = values[1].strip.to_f
        end

        costs
      end

      def total_weight(contents)
        weight = 0
        contents.each do |item|
          weight += item.quantity * (item.variant.weight || preferred_default_weight)
        end

        weight
      end
    end
  end
end