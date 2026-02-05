class Charge < ApplicationRecord
  has_many :disputes

  enum :status, { succeeded: "succeeded", refunded: "refunded", failed: "failed" }, default: "succeeded"

  validates :amount_cents, presence: true
  validates :currency, presence: true
  validates :customer_email, presence: true
end
