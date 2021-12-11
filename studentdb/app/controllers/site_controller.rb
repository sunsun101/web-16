# frozen_string_literal: true

# Top-level site controller
class SiteController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index; end

  def get_users
    @users = User.all
    respond_to do |format|
      format.js { render :json => @users }
    end
  end

  def admin_dashboard
    authorize :site, :admin_dashboard?
  end

  def users
    p "HERE"
    @users = User.all
    if params[:id]
      @user = User.find(params[:id])
    end
    respond_to do |format|
      if @user.update(user_params)
        # flash[:success] = "User updated"
        format.html { redirect_to admin_dashboard_url, notice: "User was successfully updated." }
        format.json { render :admin_dashboard, status: :ok, location: @user }
        format.js
      else
        flash[:error] = "Error in updating User"
        format.html { render :admin_dashboard, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def destroy
    if params[:id]
      User.destroy(params[:id])
    end
    redirect_to(request.referrer)
  end

  private

  def user_params
    params[:user] = {}
    params[:user][:email] = params[:email]
    params[:user][:is_admin] = params[:is_admin]
    params.require(:user).permit(:email, :is_admin)
  end
end
