class SessionsController < ApplicationController
  allow_browser versions: :modern

  def new
  end

  def create
    if user = User.authenticate_by(email_address: params[:email_address], password: params[:password])
      session[:user_id] = user.id
      audit_action("user.login", user)
      redirect_to root_path, notice: "Signed in successfully!"
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    audit_action("user.logout", current_user) if current_user
    session[:user_id] = nil
    redirect_to new_session_path, notice: "Signed out."
  end
end
