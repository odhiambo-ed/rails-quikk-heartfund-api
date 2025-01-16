class Donation < ApplicationRecord
  validates :amount, presence: true
  validates :reference, presence: true
  validates :customer_no, presence: true
end
