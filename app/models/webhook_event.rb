class WebhookEvent < ApplicationRecord
  validates :event_type, presence: true
  validates :external_id, presence: true, uniqueness: true
  validates :payload, presence: true

  # Validate JSON structure
  validate :payload_has_required_fields

  private

  def payload_has_required_fields
    return if payload.blank?

    required = %w[type id data]
    missing = required - payload.keys
    errors.add(:payload, "missing required fields: #{missing.join(', ')}") if missing.any?

    if payload["data"].present?
      data_obj = payload.dig("data", "object") || {}
      data_required = %w[id charge amount currency status]
      missing_data = data_required - data_obj.keys
      errors.add(:payload, "missing data fields: #{missing_data.join(', ')}") if missing_data.any?
    end
  end
end
