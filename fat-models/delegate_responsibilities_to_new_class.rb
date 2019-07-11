# before
class Order < ActiveRecord::Base

  def self.find_purchased
   # ...
  end

  def self.find_waiting_for_review
   # ...
  end

  def self.find_waiting_for_sign_off
    # ...
  end

  def self.find_waiting_for_sign_off
    # ...
  end

  def self.advanced_search(fields, options = {})
    # ...
  end

  def self.simple_search(terms)
    # ...
  end

  def to_xml
    # ...
  end

  def to_json
    # ...
  end

  def to_csv
    # ...
  end

  def to_pdf
    # ...
  end
end

# after -
class Order < ActiveRecord::Base

  def converter
    OrderConverter.new(self)
  end

  def self.find_purchased
    # ...
  end

  def self.find_waiting_for_review
    # ...
  end

  def self.find_waiting_for_sign_off
    # ...
  end

  def self.find_waiting_for_sign_off
    # ...
  end

  def self.advanced_search(fields, options = {})
    # ...
  end

  def self.simple_search(terms)
    # ...
  end
end

class OrderConverter
  attr_reader :order

  def initialize(order)
    @order = order
  end

  def to_xml
    # ...
  end

  def to_json
    # ...
  end

  def to_csv
    # ...
  end

  def to_pdf
    # ...
  end
end

@order.converter.to_pdf