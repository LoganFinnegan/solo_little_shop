class CreateCoupons < ActiveRecord::Migration[7.0]
  def change
    create_table :coupons do |t|
      t.string :name
      t.string :code
      t.float :discount
      t.integer :status, default: 0

      t.references :merchant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
