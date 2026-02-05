class Dispute < ApplicationRecord
  belongs_to :charge
  has_many :evidences

  enum :status, { open: 0, evidence_submitted: 1, closed_won: 2, closed_lost: 3 }, default: :open

  validates :amount_cents, presence: true
  validates :provider_id, presence: true, uniqueness: true

  def submit_evidence!
    return if closed_won? || closed_lost?
    update!(status: :evidence_submitted)
  end

  def resolve_won!
    update!(status: :closed_won)
  end

  def resolve_lost!
    update!(status: :closed_lost)
  end

  def reopen!(reason)
    update!(status: :open, reopen_reason: reason)
  end

  def closed?
    closed_won? || closed_lost?
  end
end
