class SessionController < ApplicationController
     def new
        @user = User.new
     end

    def create
        @user = User.find_by(email: params[:user][:email])
        if @user && @user.authenticate(params[:user][:password])
          session[:pre_2fa_auth_user_id] = @user.id
          Authy::API.request_sms(id: @user.authy_id)
          redirect_to two_factor_path
        else
          @user ||= User.new(email: params[:user][:email])
          render :new
        end
    end
    
     def two_factor
        return redirect_to new_session_path unless session[:pre_2fa_auth_user_id]
     end

    def verify
        @user = User.find(session[:pre_2fa_auth_user_id])
        token = Authy::API.verify(id: @user.authy_id, token: params[:otp])
        if token.ok?
          session[:user_id] = @user.id
          session[:pre_2fa_auth_user_id] = nil
          redirect_to users_path, notice: "Loggedin Successfully"
        else
          render :two_factor, notice: "Incorrect code, please try again"
        end
    end
    
    def resend
        @user = User.find(session[:pre_2fa_auth_user_id])
        Authy::API.request_sms(id: @user.authy_id)
        redirect_to sessions_two_factor_path, notice: "Verification code re-sent"
    end

  def destroy
        session[:user_id] = nil
        redirect_to root_path, notice: "You have been logged out"
  end

end
