class Webhooks::SimulatedController < ApplicationController
  def new
  end

  def create
    # Simulate a payload from a payment provider
    payload = {
      id: SecureRandom.uuid,
      type: "charge.dispute.created",
      data: {
        object: {
          id: "dp_#{SecureRandom.hex(8)}",
          charge: "ch_#{SecureRandom.hex(8)}",
          amount: rand(1000..99999),
          currency: [ "usd", "eur", "gbp" ].sample,
          status: "needs_response",
          evidence_details: {
             due_by: 10.days.from_now.to_i
          }
        }
      }
    }

    # Create webhook event
    webhook_event = WebhookEvent.create!(
      event_type: payload[:type],
      external_id: payload[:id],
      payload: payload.deep_stringify_keys
    )

    DisputeIngestionJob.perform_later(webhook_event.id)

    flash[:notice] = "Simulated dispute webhook triggered! ID: #{payload[:id]}"
    redirect_to new_webhooks_simulated_path
  end
end
