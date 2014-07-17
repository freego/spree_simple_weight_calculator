require 'spec_helper'

module Spree
  module Calculator::Shipping
    describe ItemWeight do

      options = { preferred_costs_string: "0.5:5\n1:10\n50:20\n100:50.3",
                  preferred_handling_max: 120,
                  preferred_handling_fee: 21.5,
                  preferred_max_item_size: 35,
                  preferred_default_weight: 1 }

      let(:calculator) { Calculator::Shipping::ItemWeight.new(options) }

      let(:variant1) { double("Variant", calculator_weight: 5,
                                         width: 1,
                                         depth: 1,
                                         height: 1,
                                         price: 4) }
      let(:variant2) { double("Variant", calculator_weight: 10,
                                         width: 1,
                                         depth: 1,
                                         height: 1,
                                         price: 6) }
      let(:variant3) { double("Variant",  calculator_weight: 0.0,
                                          width: 1,
                                          depth: 1,
                                          height: 1,
                                          price: 10) }

      let(:package) { double(Stock::Package,
                             order: mock_model(Order),
                             contents: [Stock::Package::ContentItem.new(1,variant1, 4),
                                        Stock::Package::ContentItem.new(2,variant2, 6)]) }

      let(:package2) { double(Stock::Package,
                              order: mock_model(Order),
                              contents: [Stock::Package::ContentItem.new(1,variant3,1)]
        )}

      it "correctly select the default weight shipping price when no weight on the variant", :focus => true do
        calculator.available?(package2).should == true
        calculator.compute_package(package2).should == 31.5 # 10 shipping + 21.5 handling
      end

      it "correctly calculates shipping when handling fee applies" do
        calculator.available?(package).should == true
        calculator.compute_package(package).should == 221.5 # 200 cost + 21.5 handling
      end

      it "correctly calculates shipping when handling fee does not apply" do
        calculator.stub(preferred_handling_max: 10)

        calculator.available?(package).should == true
        calculator.compute_package(package).should == 200
      end

      it "does not apply to overweight order" do
        variant1.stub(calculator_weight: 100)

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

      it "correctly calculates shipping when costs string has useless spaces and newlines" do
        calculator.stub(:preferred_costs_string => %q{50:20
                                                      100:50.3


                                                      })
        calculator.available?(package).should == true
        calculator.compute_package(package).should == 221.5
      end


    end
  end
end