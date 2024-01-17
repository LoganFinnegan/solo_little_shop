class Coupon < ApplicationRecord
  validates_presence_of :name,
                        :code,
                        :discount,
                        :status

  belongs_to :merchant
  enum status: ["active", "inactive"]              
end
