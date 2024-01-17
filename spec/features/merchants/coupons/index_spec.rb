require 'rails_helper'

RSpec.describe 'Merchant coupons index', type: :feature do
  describe 'as a merchant' do
    before(:each) do
      @merch_1 = Merchant.create!(name: "Walmart", status: :enabled)

      @coup_1 = @merch_1.coupons.create!(name: "big sale", code: "b12", discount: 1, status: 0)
      @coup_2 = @merch_1.coupons.create!(name: "summer sale", code: "b13", discount: 1, status: 0)
      @coup_3 = @merch_1.coupons.create!(name: "winter sale", code: "b14", discount: 1, status: 1)

    end

    # 1. Merchant Coupons Index 
    it "displays coupons and links to their show page" do 
      # When I visit my merchant dashboard page
      visit dashboard_merchant_path(@merch_1)
      # I see a link to view all of my coupons
      expect(page).to have_content("View All Coupons")
      # When I click this link
      click_link("View All Coupons")
      # I'm taken to my coupons index page
      expect(current_path).to eq(merchant_coupons_path(@merch_1))
      # Where I see all of my coupon names including their amount off 
      # And each coupon's name is also a link to its show page.
      within "#coupon-#{@coup_1.id}" do
        expect(page).to have_content(@coup_1.name)
        expect(page).to have_link(@coup_1.name)
      end

      within "#coupon-#{@coup_2.id}" do
        expect(page).to have_content(@coup_2.name)
        expect(page).to have_link(@coup_2.name)
        click_on(@coup_2.name)
      end
      expect(current_path).to eq(merchant_coupon_path(@merch_1, @coup_2))
    end

    # 6. Merchant Coupon Index Sorted
    it "sorts coupons by status" do 
      # When I visit my coupon index page
       visit merchant_coupons_path(@merch_1)
      # I can see that my coupons are separated between active and inactive coupons.
      within '.active' do
        expect(page).to have_link(@coup_1.name)
        expect(page).to have_link(@coup_2.name)
        expect(page).to_not have_content(@coup_3.name)
      end
      
      within '.inactive' do
        expect(page).to have_link(@coup_3.name)
        expect(page).to_not have_link(@coup_1.name)
        expect(page).to_not have_link(@coup_2.name)
      end
    end
  end
end