class Webhooks::DisputesController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def create
    payload = parse_json_body
    p payload.inspect

    # Create webhook event (idempotent via unique external_id)
    #
    if WebhookEvent.find_by(external_id: payload["id"])
      webhook_event = WebhookEvent.find_by(external_id: payload["id"])
      webhook_event.update!(payload: payload)
    else
      webhook_event = WebhookEvent.create!(
        event_type: payload["type"],
        external_id: payload["id"],
        payload: payload
      )
    end

    # Enqueue background job
    DisputeIngestionJob.perform_later(webhook_event.id)

    head :ok

  rescue JSON::ParserError
    render json: { error: "Invalid JSON" }, status: :bad_request
  rescue ActiveRecord::RecordInvalid => e
    # Check if it's a duplicate webhook
    if e.message.include?("External") && e.message.include?("already been taken")
      head :ok
    else
      render json: { error: e.message }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    # Duplicate webhook - already processed
    head :ok
  end

  private

  def parse_json_body
    JSON.parse(request.body.read)
  end
end
