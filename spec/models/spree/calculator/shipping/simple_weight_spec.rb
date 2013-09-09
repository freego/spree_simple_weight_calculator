require 'spec_helper'

module Spree
  module Calculator::Shipping
    describe SimpleWeight do

      options = { preferred_costs_string: "50:20\n100:50.3",
                  preferred_handling_max: 120,
                  preferred_handling_fee: 21.5,
                  preferred_max_item_size: 35 }

      let(:calculator) { Calculator::Shipping::SimpleWeight.new(options) }

      let(:variant1) { double("Variant", weight: 5,
                                         width: 1,
                                         depth: 1,
                                         height: 1,
                                         price: 4) }
      let(:variant2) { double("Variant", weight: 10,
                                         width: 1,
                                         depth: 1,
                                         height: 1,
                                         price: 6) }

      let(:package) { double(Stock::Package,
                             order: mock_model(Order),
                             contents: [Stock::Package::ContentItem.new(variant1, 4),
                                        Stock::Package::ContentItem.new(variant2, 6)]) }

      it "correctly calculates shipping when handling fee applies" do
        calculator.available?(package).should == true
        calculator.compute(package).should == 71.8 # 50.3 cost + 21.5 handling
      end

      it "correctly calculates shipping when handling fee does not apply" do
        calculator.stub(preferred_handling_max: 10)

        calculator.available?(package).should == true
        calculator.compute(package).should == 50.3
      end

      it "does not apply to overweight order" do
        variant1.stub(weight: 100)

        calculator.available?(package).should == false
      end

      it "does not apply to order with oversize items" do
        variant1.stub(depth: 100)

        calculator.available?(package).should == false
      end

      it "does not apply with invalid costs string" do
        calculator.stub(preferred_costs_string: "")
        calculator.available?(package).should == false

        calculator.stub(preferred_costs_string: "20:")
        calculator.available?(package).should == false

        calculator.stub(preferred_costs_string: "50=20")
        calculator.available?(package).should == false

        calculator.stub(preferred_costs_string: "abc:dfg\nerge:67")
        calculator.available?(package).should == false
      end
    end
  end
end