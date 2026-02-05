class DisputeIngestionJob < ApplicationJob
  queue_as :default

  def perform(webhook_event_id)
    webhook_event = WebhookEvent.find(webhook_event_id)
    payload = webhook_event.payload.deep_symbolize_keys

    event_type = payload[:type]
    data = payload.dig(:data, :object)

    case event_type
    when "charge.dispute.created"
      process_dispute_created(data)
    when "charge.dispute.updated"
      process_dispute_updated(data)
    end

    # Mark as processed
    webhook_event.update!(processed_at: Time.current)

  rescue => e
    Rails.logger.error "Failed to process webhook #{webhook_event_id}: #{e.message}"
    raise
  end

  private

  def process_dispute_created(data)
    # Find or create charge
    charge = Charge.find_or_create_by!(provider_id: data[:charge]) do |c|
      c.amount_cents = data[:amount]
      c.currency = data[:currency]
      c.customer_email = "customer_#{SecureRandom.hex(4)}@example.com"
      c.status = "succeeded"
    end

    # Create dispute (skip if already exists)
    return if Dispute.exists?(provider_id: data[:id])

    Dispute.create!(
      charge: charge,
      provider_id: data[:id],
      amount_cents: data[:amount],
      status: :open
    )

    Rails.logger.info "Created dispute #{data[:id]} for Charge #{charge.id}"
  end

  def process_dispute_updated(data)
    dispute = Dispute.find_by(provider_id: data[:id])
    return unless dispute

    # Update status based on webhook
    case data[:status]
    when "won"
      dispute.resolve_won! if dispute.status == "evidence_submitted"
    when "lost"
      dispute.resolve_lost! if dispute.status == "evidence_submitted"
    end

    Rails.logger.info "Updated dispute #{data[:id]} to status: #{data[:status]}"
  end
end
