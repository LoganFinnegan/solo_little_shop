class Merchant < ApplicationRecord
  validates :name, presence: true

  has_many :items, dependent: :destroy
  has_many :invoices, through: :items
  has_many :invoice_items, through: :items
  has_many :customers, through: :invoices
  has_many :transactions, through: :invoices
  has_many :coupons, dependent: :destroy

  enum status: { disabled: 0, enabled: 1 }

  def transactions
    Transaction.joins(invoice: { invoice_items: :item }).where(items: { merchant_id: id })
  end

  def top_customers
    Customer.joins(invoices: :transactions)
            .joins("JOIN invoice_items ON invoice_items.invoice_id = invoices.id")
            .joins("JOIN items ON items.id = invoice_items.item_id AND items.merchant_id = #{id}")
            .select('customers.*, COUNT(transactions.id) AS transactions_count')
            .where(transactions: { result: 'success' })
            .group('customers.id')
            .order('transactions_count DESC')
            .limit(5)
  end

  def not_yet_shipped_ascending
    InvoiceItem.find_by_sql ["SELECT
    items.name,
    invoice_items.invoice_id,
    invoice_items.status,
    invoices.created_at
  FROM
    items
    JOIN invoice_items ON items.id = invoice_items.item_id
    JOIN invoices ON invoices.id = invoice_items.invoice_id
  WHERE
    items.merchant_id = #{id}
    AND (invoice_items.status = '0'
    OR invoice_items.status = '1')
    ORDER BY invoices.created_at;"]
  end

  def top_earning_items #presentation
    #self.items.joins(invoices: :transactions).where("transactions.result = 1").group("items.id").select("SUM(invoice_items.quantity * invoice_items.unit_price) as total_revenue, items.*").order("total_revenue desc").limit(5)
    Item.find_by_sql(["SELECT items.*, SUM(invoice_items.quantity * invoice_items.unit_price) as total_revenue
    FROM
    items
    JOIN invoice_items ON items.id = invoice_items.item_id
    JOIN invoices ON invoice_items.invoice_id = invoices.id
    JOIN transactions ON invoices.id = transactions.invoice_id
    WHERE items.merchant_id = #{self.id} AND transactions.result = 0
    GROUP BY items.id
    ORDER BY total_revenue DESC
    LIMIT 5", id])
  end

  def merchant_invoices
    Invoice.joins(:items).where("#{self.id} = items.merchant_id").distinct #US-13 NKL
  end

  def self.top_five_merchants
    self.joins([invoices: :transactions], :invoice_items)
      .where("transactions.result = ?", 0)
      .select("merchants.name, merchants.id, SUM(invoice_items.unit_price * invoice_items.quantity) AS revenue")
      .group("merchants.id")
      .order("revenue DESC")
      .limit(5)
  end

  def total_invoice_revenue(invoice)
    invoice.invoice_items.joins(:item)
      .where("items.merchant_id = #{self.id}")
      .sum("quantity * invoice_items.unit_price")
  end

  def unique_coupon_code?(code)
    coupons.where.not(code: code).count == coupons.count
  end

  def five_active_coupons?
    coupons.where(status: 0).count >= 5
  end

  def use_count
    invoices.joins(:transactions)
      .where("transactions.result = ? AND invoices.status = ?", 0, 2)
      .count
  end

  # def apply_coupons(invoice)
  #   format_dollars(total_invoice_revenue(invoice) - discount_amount)
  # end

  # def discount_amount
  #   coupons.where(status: 0).maximum(:discount)
  # end

  # def coupon_used
  #   coupons.where(discount: discount_amount).first
  # end
end
