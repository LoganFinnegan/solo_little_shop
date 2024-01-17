require 'rails_helper'

RSpec.describe Coupon, type: :model do
  describe "relationships" do
     it { should validate_presence_of(:name) }
     it { should validate_presence_of(:code) }
     it { should validate_presence_of(:discount) }
     it { should validate_presence_of(:status) }
  end

  
end
