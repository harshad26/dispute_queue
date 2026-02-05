class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :authenticated?

  private
    def current_user
      @current_user ||= User.find_by(id: session[:user_id])
    end

    def authenticated?
      current_user.present?
    end

    def require_authentication
      redirect_to new_session_path, alert: "Please sign in to continue." unless authenticated?
    end

    def audit_action(action, target = nil, details = {})
      AuditLog.create(
        user: current_user, # Can be nil
        action: action,
        target: target,
        details: details
      )
    end
end
