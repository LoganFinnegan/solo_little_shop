require 'rails_helper'

RSpec.describe 'merchant coupon show', type: :feature do
  describe 'as a merchant' do
    before(:each) do
      @merch_1 = Merchant.create!(name: "Walmart", status: :enabled)
      
      @item_1 = @merch_1.items.create!(name: "Apple", description: "red apple", unit_price:10)

      @coup_1 = @merch_1.coupons.create!(name: "Spring Final Sale $11 Off", code: "ss11", discount: 11, status: 0)
      @coup_2 = @merch_1.coupons.create!(name: "Spring Final Sale $12 Off", code: "ss12", discount: 12, status: 1)

      @cust_1 = Customer.create!(first_name: "Larry", last_name: "Johnson")

      @inv_1 = @cust_1.invoices.create!(status: :completed )
      
      @inv_2 = @cust_1.invoices.create!(status: :completed )

      @tran_1 = @inv_1.transactions.create!(credit_card_number: "2222 2222 2222 2222", credit_card_expiration_date: "01/2021", result: :success )

      @tran_2 = @inv_2.transactions.create!(credit_card_number: "2222 2222 2222 2222", credit_card_expiration_date: "01/2021", result: :failed )

      @ii_1 = InvoiceItem.create!(invoice: @inv_1, item: @item_1, quantity: 10, unit_price: 10, status: :shipped )

      @ii_1 = InvoiceItem.create!(invoice: @inv_2, item: @item_1, quantity: 10, unit_price: 10, status: :shipped )
    end

    # 3. Merchant Coupon Show Page 
    it 'shows coupon info/stats' do
      # When I visit a merchant's coupon show page 
      visit merchant_coupon_path(@merch_1, @coup_1)
      # I see that coupon's name and code 
      expect(page).to have_content(@coup_1.name)
      expect(page).to have_content(@coup_1.code)
      # And I see the percent/dollar off value
      expect(page).to have_content(@coup_1.discount)
      # As well as its status (active or inactive)
      expect(page).to have_content(@coup_1.status)
      # And I see a count of how many times that coupon has been used.
      # (Note: "use" of a coupon should be limited to successful transactions.)
      expect(page).to have_content(@coup_1.merchant.use_count)
      expect(page).to have_content("Times used: 1")
    end

    # 4. Merchant Coupon Deactivate
    it "can deactivate coupons" do 
      # When I visit one of my active coupon's show pages
      visit merchant_coupon_path(@merch_1, @coup_1)
      # I see a button to deactivate that coupon
      expect(page).to have_button("Deactivate Coupon")
      # When I click that button
      click_button("Deactivate Coupon")
      # I'm taken back to the coupon show page 
      expect(current_path).to eq(merchant_coupon_path(@merch_1, @coup_1))
      # And I can see that its status is now listed as 'inactive'.
      expect(page).to have_content("Status: inactive")
    end
    
    describe "sad paths" do
      it "Coupon cannot be deactivated on pending invoices" do
        # * Sad Paths to consider: 
        # 1. A coupon cannot be deactivated if there are any pending invoices with that coupon.
        inv_3 = @cust_1.invoices.create!(status: :in_progress )

        @tran_1 = inv_3.transactions.create!(credit_card_number: "2222 2222 2222 2222", credit_card_expiration_date: "01/2021", result: :success )

        ii_3 = InvoiceItem.create!(invoice: inv_3, item: @item_1, quantity: 10, unit_price: 10, status: :shipped )

        visit merchant_coupon_path(@merch_1, @coup_1)
      
        expect(page).to have_button("Deactivate Coupon")
        
        click_button("Deactivate Coupon")
        
        expect(current_path).to eq(merchant_coupon_path(@merch_1, @coup_1))

        expect(page).to have_content("Cannot deactivate coupons with pending invoices.")
      
        expect(page).to have_content("Status: active")

      end
    end

    # 5. Merchant Coupon Activate
    it "can activate coupons" do 
      # When I visit one of my inactive coupon show pages
      visit merchant_coupon_path(@merch_1, @coup_2)
      # I see a button to activate that coupon
      expect(page).to have_button("Activate Coupon")
      # When I click that button
      click_button("Activate Coupon")
      # I'm taken back to the coupon show page 
      expect(current_path).to eq(merchant_coupon_path(@merch_1, @coup_2))
      # And I can see that its status is now listed as 'active'.
      expect(page).to have_content("Status: active")
    end
  end
end