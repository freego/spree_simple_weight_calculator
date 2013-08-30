require 'spec_helper'

describe Spree::Calculator::SimpleWeight do

  let(:calculator) { Spree::Calculator::SimpleWeight.new(:preferred_costs_string => "50:20\n100:50.3",
                                                         :preferred_handling_max => 120,
                                                         :preferred_handling_fee => 21.5,
                                                         :preferred_max_item_size => 35) }

  let(:variant1) { double("Variant", :weight => 5,
                                     :width => 1,
                                     :depth => 1,
                                     :height => 1) }
  let(:variant2) { double("Variant", :weight => 10,
                                     :width => 1,
                                     :depth => 1,
                                     :height => 1) }

  let(:lineitem1) { mock_model(Spree::LineItem, :variant => variant1,
                                                :quantity => 4,
                                                :total => 16)}
  let(:lineitem2) { mock_model(Spree::LineItem, :variant => variant2,
                                                :quantity => 6,
                                                :total => 36)}

  let(:order) { mock_model(Spree::Order, :line_items => [lineitem1, lineitem2]) }


  it "correctly calculates shipping when handling fee applies" do
    calculator.available?(order).should == true
    calculator.compute(order).should == 71.8 # 50.3 cost + 21.5 handling
  end

  it "correctly calculates shipping when handling fee does not apply" do
    calculator.stub(:preferred_handling_max => 10)

    calculator.available?(order).should == true
    calculator.compute(order).should == 50.3
  end

  it "does not apply to overweight order" do
    variant1.stub(:weight => 100)

    calculator.available?(order).should == false
  end

  it "does not apply to order with oversize items" do
    variant1.stub(:depth => 100)

    calculator.available?(order).should == false
  end

  it "does not apply with invalid costs string" do
    calculator.stub(:preferred_costs_string => "")
    calculator.available?(order).should == false

    calculator.stub(:preferred_costs_string => "20:")
    calculator.available?(order).should == false

    calculator.stub(:preferred_costs_string => "50=20")
    calculator.available?(order).should == false

    calculator.stub(:preferred_costs_string => "abc:dfg\nerge:67")
    calculator.available?(order).should == false
  end

end