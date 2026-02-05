class Evidence < ApplicationRecord
  belongs_to :dispute
  has_one_attached :file

  validates :description, presence: true
end
