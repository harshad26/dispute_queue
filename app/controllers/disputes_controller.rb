class DisputesController < ApplicationController
  before_action :require_authentication
  before_action :set_dispute, only: %i[ show update upload_evidence destroy_evidence ]

  def index
    @disputes = Dispute.includes(:charge)
                       .order(status: :asc, created_at: :desc)
  end

  def show
  end

  def update
    unless current_user.can_manage_disputes?
      redirect_to dispute_path(@dispute), alert: "You are not authorized to manage disputes."
      return
    end

    case params[:transition]
    when "submit_evidence"
      @dispute.submit_evidence!
      audit_action("dispute.submit_evidence", @dispute)
      flash[:notice] = "Evidence submitted successfully."
    when "won"
      @dispute.resolve_won!
      audit_action("dispute.resolved_won", @dispute)
      flash[:notice] = "Dispute resolved as WON."
    when "lost"
      @dispute.resolve_lost!
      audit_action("dispute.resolved_lost", @dispute)
      flash[:notice] = "Dispute resolved as LOST."
    when "reopen"
      if current_user.can_reopen?
        reason = params[:reopen_reason]
        @dispute.reopen!(reason)
        audit_action("dispute.reopen", @dispute, { reason: reason })
        flash[:notice] = "Dispute reopened."
      else
        flash[:alert] = "Only admins can reopen disputes."
      end
    end

    redirect_to dispute_path(@dispute)
  end

  def upload_evidence
    unless current_user.can_manage_disputes?
      redirect_to dispute_path(@dispute), alert: "You are not authorized to upload evidence."
      return
    end

    if params[:evidence_file].present?
      evidence = @dispute.evidences.build(
        description: params[:description],
        file: params[:evidence_file]
      )

      if evidence.save
        audit_action("dispute.upload_evidence", @dispute, { filename: params[:evidence_file].original_filename })
        flash[:notice] = "Evidence attached!"
      else
        flash[:alert] = "Could not attach evidence: #{evidence.errors.full_messages.join(', ')}"
      end
    else
      flash[:alert] = "Please select a file."
    end
    redirect_to dispute_path(@dispute)
  end

  def destroy_evidence
    unless current_user.can_remove_evidence?
      redirect_to dispute_path(@dispute), alert: "Only admins can remove evidence."
      return
    end

    evidence = @dispute.evidences.find(params[:evidence_id])
    audit_action("dispute.remove_evidence", @dispute, { filename: evidence.file.filename.to_s })
    evidence.destroy
    redirect_to dispute_path(@dispute), notice: "Evidence removed."
  end

  private
    def set_dispute
      @dispute = Dispute.find(params[:id])
    end
end
