
class Spree::Calculator::SimpleWeight < Spree::Calculator
  preference :costs_string, :text, :default => "1:5\n2:7\n5:10\n10:15\n100:50"
  preference :default_weight, :decimal, :default => 1
  preference :max_item_size, :decimal, :default => 0
  preference :handling_fee, :decimal, :default => 0
  preference :handling_max, :decimal, :default => 0

  attr_accessible :preferred_costs_string,  :preferred_max_item_size, :preferred_handling_max, :preferred_handling_fee, :preferred_default_weight

  def self.description
    I18n.t :simple_weight
  end

  def self.register
    super
  end

  def available?(order)
    return false if order_overweight?(order) or !costs_string_valid?
    if self.preferred_max_item_size > 0
      order.line_items.each do |item|
        return false if item_oversized?(item) or item_overweight?(item)
      end
    end
    true
  end

  def compute(object)
    return 0 if object.nil?
    case object
      when Spree::Order
        compute_order(object)
      when Spree::Shipment
        compute_order(object.order)
    end
  end

  private

  def compute_order(order)
    line_items_total = order.line_items.sum(&:total)
    handling_fee = self.preferred_handling_max > line_items_total ? self.preferred_handling_fee : 0

    total_weight = total_weight(order)
    costs = costs_string_to_hash(self.preferred_costs_string)
    weight_class = costs.keys.select { |w| total_weight <= w }.min
    shipping_costs = costs[weight_class]

    return 0 unless shipping_costs
    shipping_costs + handling_fee
  end

  def costs_string_valid?
    self.preferred_costs_string.size > 0
  end

  def item_oversized?(item)
    return false if self.preferred_max_item_size == 0
    variant = item.variant
    sizes = [ variant.width ? variant.width : 0 , variant.depth ? variant.depth : 0 , variant.height ? variant.height : 0 ].sort!
    sizes[0] > self.preferred_max_item_size ? true : false
  end

  def order_overweight?(order)
    total_weight = total_weight(order)
    max_weight = costs_string_to_hash(self.preferred_costs_string).keys.max
    total_weight > max_weight ? true : false
  end

  def costs_string_to_hash(costs_string)
    costs = {}
    costs_string.split.each do |cost_string|
      values = cost_string.strip.split(':')
      costs[values[0].strip.to_f] = values[1].strip.to_f
    end
    costs
  end

  def total_weight(order)
    weight = 0
    order.line_items.each do |item|
      weight += item.quantity * (item.variant.weight || self.preferred_default_weight)
    end
    weight
  end

end
