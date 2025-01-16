class CreateDonations < ActiveRecord::Migration[8.0]
  def change
    create_table :donations do |t|
      t.decimal :amount
      t.string :reference
      t.string :customer_no

      t.timestamps
    end
  end
end
