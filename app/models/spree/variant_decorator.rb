module Spree
  Variant.class_eval do
    # you can add custom weight logic here
    def calculator_weight
      weight
    end
  end
end