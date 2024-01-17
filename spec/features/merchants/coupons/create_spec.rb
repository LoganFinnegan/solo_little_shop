require 'rails_helper'

RSpec.describe 'merchant coupon create', type: :feature do
  describe 'as a merchant' do
    before(:each) do
      @merch_1 = Merchant.create!(name: "Walmart", status: :enabled)

      @coup_1 = @merch_1.coupons.create!(name: "Spring Final Sale $11 Off", code: "ss11", discount: 11, status: 0)
    end

    # 2. Merchant Coupon Create 
    it "can create new coupon" do 
      # When I visit my coupon index page 
      visit merchant_coupons_path(@merch_1)
      # I see a link to create a new coupon.
      expect(page).to have_link("Create a New Coupon")
      # When I click that link 
      click_link("Create a New Coupon")
      # I am taken to a new page where I see a form to add a new coupon.
      expect(current_path).to eq(new_merchant_coupon_path(@merch_1))
      # When I fill in that form with a name, unique code, an amount, and whether that amount is a percent or a dollar amount
      fill_in(:name, with: "Spring Sale $10 Off")
      fill_in(:code, with: "ss10")
      fill_in(:discount, with: 10)
      # And click the Submit button
      click_on("Submit")
      # I'm taken back to the coupon index page 
      expect(current_path).to eq(merchant_coupons_path(@merch_1))
      # And I can see my new coupon listed.
      expect(page).to have_content("Spring Sale $10 Off")
    end 

    describe "sad paths" do
      it "Coupon code entered is NOT unique" do
        visit new_merchant_coupon_path(@merch_1)

        fill_in(:name, with: "Spring Final Sale $11 Off")
        fill_in(:code, with: "ss11")
        fill_in(:discount, with: 11)
        # And click the Submit button
        click_on("Submit")

        expect(page).to have_content("Coupon code already exists")

        expect(current_path).to eq(new_merchant_coupon_path(@merch_1))
      end

      it "Merchant already has 5 active coupons" do 
        coup_2 = @merch_1.coupons.create!(name: "summer sale 13", code: "b13", discount: 1, status: 0)
        coup_3 = @merch_1.coupons.create!(name: "summer sale 14", code: "b14", discount: 1, status: 0)
        coup_4 = @merch_1.coupons.create!(name: "summer sale 15", code: "b15", discount: 1, status: 0)
        coup_5 = @merch_1.coupons.create!(name: "summer sale 16", code: "b16", discount: 1, status: 0)

        visit new_merchant_coupon_path(@merch_1)

        fill_in(:name, with: "Spring Final Sale $15 Off")
        fill_in(:code, with: "ss15")
        fill_in(:discount, with: 15)
        # And click the Submit button
        click_on("Submit")

        expect(page).to have_content("You have reached max coupon limit of 5.")
        
        expect(current_path).to eq(merchant_coupons_path(@merch_1))
      end
    end
  end
end