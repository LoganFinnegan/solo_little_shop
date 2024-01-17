require "rails_helper"

RSpec.describe "merchant's invoice page", type: :feature do
  it "shows the invoice status and ID, and date formatted like 'Monday, July 18, 2019' and customer full name" do
    merchant_1 = Merchant.create!(name: "Walmart")
    merchant_2 = Merchant.create!(name: "Temu")
    item1 = merchant_1.items.create!(name: "popcan", description: "fun", unit_price: 100)
    item2 = merchant_1.items.create!(name: "popper", description: "fun", unit_price: 156)
    item3 = merchant_1.items.create!(name: "zipper", description: "pants", unit_price: 340)
    item4 = merchant_2.items.create!(name: "zoozah", description: "doot", unit_price: 354)
    item5 = merchant_2.items.create!(name: "oiko", description: "zeelk", unit_price: 4)
    item6 = merchant_2.items.create!(name: "onion pillow", description: "kids", unit_price: 1030)
    item7 = merchant_2.items.create!(name: "stash", description: "costume", unit_price: 1070)
    customer1 = Customer.create!(first_name: "John", last_name: "Smith")
    customer2 = Customer.create!(first_name: "Jane", last_name: "Sornes")
    customer3 = Customer.create!(first_name: "Jaques", last_name: "Snipes")
    invoice1 = customer1.invoices.create!(status: 2)
    invoice2 = customer2.invoices.create!(status: 2)
    invoice3 = customer3.invoices.create!(status: 2)
    invoice_item1 = invoice1.invoice_items.create!(item_id: item1.id, quantity: 1, unit_price: 100, status: 1)
    invoice_item2 = invoice1.invoice_items.create!(item_id: item2.id, quantity: 2, unit_price: 156, status: 0)
    invoice_item3 = invoice2.invoice_items.create!(item_id: item3.id, quantity: 1, unit_price: 340, status: 1)
    invoice_item4 = invoice2.invoice_items.create!(item_id: item4.id, quantity: 4, unit_price: 354, status: 0)
    invoice_item5 = invoice3.invoice_items.create!(item_id: item5.id, quantity: 23, unit_price: 4, status: 1)
    invoice_item6 = invoice3.invoice_items.create!(item_id: item6.id, quantity: 6, unit_price: 1030, status: 2)
    transaction1 = invoice1.transactions.create!(credit_card_number: 1238567890123476, credit_card_expiration_date: "04/26", result: 0)
    transaction2 = invoice2.transactions.create!(credit_card_number: 1238567590123476, credit_card_expiration_date: "04/26", result: 0)
    transaction3 = invoice3.transactions.create!(credit_card_number: 1238634646123476, credit_card_expiration_date: "04/26", result: 0)

    visit merchant_invoice_path(merchant_1, invoice1)

    expect(current_path).to eq("/merchants/#{merchant_1.id}/invoices/#{invoice1.id}")

    expect(page).to have_content(invoice1.id)
    expect(page).to have_content(invoice1.status)
    expect(page).to have_content(invoice1.created_at.strftime("%A, %B %d, %Y"))
    expect(page).to have_content(invoice1.customer.first_name + " " + invoice1.customer.last_name)
  end

  it "lists all items on invoice including: name, quantity, price, status and I do not see any information related to Items for other merchants" do
    merchant_1 = Merchant.create!(name: "Walmart")
    merchant_2 = Merchant.create!(name: "Temu")
    item1 = merchant_1.items.create!(name: "popcan", description: "fun", unit_price: 100)
    item2 = merchant_1.items.create!(name: "popper", description: "fun", unit_price: 156)
    item3 = merchant_2.items.create!(name: "copper", description: "money", unit_price: 243)
    customer1 = Customer.create!(first_name: "John", last_name: "Smith")
    customer2 = Customer.create!(first_name: "Jane", last_name: "Sornes")
    invoice1 = customer1.invoices.create!(status: 2)
    invoice2 = customer2.invoices.create!(status: 2)
    invoice_item1 = invoice1.invoice_items.create!(item_id: item1.id, quantity: 1, unit_price: 99, status: 0)
    invoice_item2 = invoice1.invoice_items.create!(item_id: item2.id, quantity: 2, unit_price: 133, status: 1)
    invoice_item3 = invoice1.invoice_items.create!(item_id: item3.id, quantity: 1, unit_price: 210, status: 2)
    invoice_item4 = invoice2.invoice_items.create!(item_id: item1.id, quantity: 1, unit_price: 340, status: 2)
    transaction1 = invoice1.transactions.create!(credit_card_number: 1238567890123476, credit_card_expiration_date: "04/26", result: 0)
    transaction2 = invoice2.transactions.create!(credit_card_number: 1238567590123476, credit_card_expiration_date: "04/26", result: 0)

    visit merchant_invoice_path(merchant_1, invoice1)

    expect(current_path).to eq("/merchants/#{merchant_1.id}/invoices/#{invoice1.id}")

    expect(page).to have_content("Item Information:")
    expect(page).to have_content(item1.name)
    expect(page).to have_content(item2.name)
    expect(page).to_not have_content(item3.name)
    expect(page).to have_content(invoice_item1.quantity)
    expect(page).to have_content(invoice_item2.quantity)
    expect(page).to have_content(invoice_item1.unit_price.to_f / 100)
    expect(page).to have_content(invoice_item2.unit_price.to_f / 100)
    expect(page).to have_content(invoice_item1.status)
    expect(page).to have_content(invoice_item2.status)
  end

  it "shows the total revenue that will be generated from all of my items on the invoice" do
    merchant_1 = Merchant.create!(name: "Walmart")
    merchant_2 = Merchant.create!(name: "Temu")
    item1 = merchant_1.items.create!(name: "popcan", description: "fun", unit_price: 100)
    item2 = merchant_1.items.create!(name: "popper", description: "fun", unit_price: 156)
    item3 = merchant_2.items.create!(name: "copper", description: "money", unit_price: 243)
    customer1 = Customer.create!(first_name: "John", last_name: "Smith")
    customer2 = Customer.create!(first_name: "Jane", last_name: "Sornes")
    invoice1 = customer1.invoices.create!(status: 2)
    invoice2 = customer2.invoices.create!(status: 2)
    invoice_item1 = invoice1.invoice_items.create!(item_id: item1.id, quantity: 1, unit_price: 99, status: 0)
    invoice_item2 = invoice1.invoice_items.create!(item_id: item2.id, quantity: 2, unit_price: 133, status: 1)
    invoice_item3 = invoice1.invoice_items.create!(item_id: item3.id, quantity: 1, unit_price: 210, status: 2)
    invoice_item4 = invoice2.invoice_items.create!(item_id: item1.id, quantity: 1, unit_price: 340, status: 2)
    transaction1 = invoice1.transactions.create!(credit_card_number: 1238567890123476, credit_card_expiration_date: "04/26", result: 0)
    transaction2 = invoice2.transactions.create!(credit_card_number: 1238567590123476, credit_card_expiration_date: "04/26", result: 0)

    visit merchant_invoice_path(merchant_1, invoice1)

    expect(current_path).to eq("/merchants/#{merchant_1.id}/invoices/#{invoice1.id}")

    expect(page).to have_content("Total Expected Revenue: $#{merchant_1.total_invoice_revenue(invoice1).to_f / 100}") #365
  end

  it "the invoice item status is a select box and can change the invoice_items status" do
    merchant_1 = Merchant.create!(name: "Walmart")
    merchant_2 = Merchant.create!(name: "Temu")
    item1 = merchant_1.items.create!(name: "popcan", description: "fun", unit_price: 100)
    item2 = merchant_1.items.create!(name: "popper", description: "fun", unit_price: 156)
    item3 = merchant_2.items.create!(name: "copper", description: "money", unit_price: 243)
    customer1 = Customer.create!(first_name: "John", last_name: "Smith")
    customer2 = Customer.create!(first_name: "Jane", last_name: "Sornes")
    invoice1 = customer1.invoices.create!(status: 2)
    invoice2 = customer2.invoices.create!(status: 2)
    invoice_item1 = invoice1.invoice_items.create!(item_id: item1.id, quantity: 1, unit_price: 99, status: 0)

    visit merchant_invoice_path(merchant_1, invoice1)
    expect(current_path).to eq("/merchants/#{merchant_1.id}/invoices/#{invoice1.id}")
    expect(page).to have_content("Update Item Status")
    expect(page).to have_content("pending")

    select "Packaged", from: :status
    click_button "Update Item Status"
    expect(current_path).to eq("/merchants/#{merchant_1.id}/invoices/#{invoice1.id}")
    expect(page).to have_content("Pending")
  end

  # 7. Merchant Invoice Show Page: Subtotal and Grand Total Revenues
  xit "shows totals before and after coupons as well as coupn info" do 
      merch_1 = Merchant.create!(name: "Walmart", status: :enabled)
      merch_2 = Merchant.create!(name: "Target", status: :enabled)
      
      item_1 = merch_1.items.create!(name: "Apple", description: "red apple", unit_price:10)
      item_2 = merch_2.items.create!(name: "Orange", description: "red apple", unit_price:10)

      coup_1 = merch_1.coupons.create!(name: "Spring Final Sale $11 Off", code: "ss11", discount: 11, status: 0)
      coup_2 = merch_1.coupons.create!(name: "Spring Final Sale $12 Off", code: "ss12", discount: 12, status: 1)
      coup_3 = merch_2.coupons.create!(name: "Coupon 3", code: "ss13", discount: 15, status: 0)

      cust_1 = Customer.create!(first_name: "Larry", last_name: "Johnson")

      inv_1 = cust_1.invoices.create!(status: :completed )
      inv_2 = cust_1.invoices.create!(status: :completed )

      tran_1 = inv_1.transactions.create!(credit_card_number: "2222 2222 2222 2222", credit_card_expiration_date: "01/2021", result: :success )
      tran_2 = inv_2.transactions.create!(credit_card_number: "2222 2222 2222 2222", credit_card_expiration_date: "01/2021", result: :failed )

      ii_1 = InvoiceItem.create!(invoice: inv_1, item: item_1, quantity: 1000, unit_price: 100, status: :shipped )
      ii_2 = InvoiceItem.create!(invoice: inv_1, item: item_1, quantity: 2000, unit_price: 100, status: :shipped )
      ii_3 = InvoiceItem.create!(invoice: inv_1, item: item_2, quantity: 3000, unit_price: 100, status: :shipped )

    # When I visit one of my merchant invoice show pages
    visit merchant_invoice_path(merch_1, inv_1)
    # I see the subtotal for my merchant from this invoice (that is, the total that does not include coupon discounts)
    save_and_open_page
    expect(page).to have_content("Total Expected Revenue: $6000")
    # And I see the grand total revenue after the discount was applied
    expect(page).to have_content("Total Expected Revenue After Coupons: $5999.74")
    # And I see the name and code of the coupon used as a link to that coupon's show page.
    within '.coup-used' do
      expect(page).to have_content(coup_1.name)
      expect(page).to have_content(coup_1.code)
      expect(page).to have_link(coup_1.name)
    end
    # @invoice.merchants.first.coupons
  end
end

# notes:
# - filter out invoices used making sure only applied
# - only display total expected rev after coups once

# <!--
# <% @invoice.merchants.each do |merchant| %>
#   <% if merchant.coupons.active %> 
#     <h3><%= "Total Expected Revenue After Coupons: $#{merchant.apply_coupons(@invoice)}"%></h3>
#     
#     <p> Name: <%= merchant.coupon_used.name %> </p>
#     <p> Code: <%= merchant.coupon_used.code %> </p>
#   <% else %>
#     <h3><%= "Total Expected Revenue After Coupons: $#{merchant.total_invoice_revenue(@invoice)}"%></h3>
#   <% end %>
# <% end %>
# 
# 
# <section class="coup-used">
#   <h3> Invoices Used </h3>
#     <% @invoice.merchants.each do |merchant| %>
#       <% if merchant.coupons.active %>   
#         <h4> Name: <%= merchant.coupon_used.name %> </h4>
#         <p> Code: <%= merchant.coupon_used.code %> </p>
#       <%end%>
#     <%end %>
# </section> 
# -->