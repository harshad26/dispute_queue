class User < ApplicationRecord
  has_secure_password

  enum :role, { read_only: 0, reviewer: 1, admin: 2 }, default: :read_only

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def can_manage_disputes?
    admin? || reviewer?
  end

  def can_reopen?
    admin?
  end

  def can_remove_evidence?
    admin?
  end
end
