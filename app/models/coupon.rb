class Coupon < ApplicationRecord
  validates_presence_of :name,
                        :code,
                        :discount,
                        :status

   enum status: ["active", "inactive"]              
  
  belongs_to :merchant
end
