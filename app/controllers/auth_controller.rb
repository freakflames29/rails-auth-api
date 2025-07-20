class AuthController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  def index
    @users = User.all
    render json: @users.as_json(only: [:id, :username])
  end

  def refresh
    begin
      token = params[:refresh_token]
      user = User.find_by(refresh_token_digest: token)
      if user
        # puts "The Refrsh token user >>>>>>>>>>#{user.inspect}"
        newToken = generate_token(user)

        user.update!(refresh_token_digest: newToken[:refresh_token])

        render json: { access_token: newToken[:access_token], refresh_token: newToken[:refresh_token] }, status: :created

      else
        render json: { msg: "Invalid Refresh token" }, status: :bad_request
      end
    rescue => e
      render json: { msg: "Refresh token not valid" }, status: :bad_request
    end
  end

  def signup
    puts "params >>>>>#{permit_params}"
    # render plain: "Send"
    @user = User.new(permit_params)
    if @user.save
      render json: { msg: "Signed up succesfully" }, status: :created
    else
      render json: @user.errors.full_messages, status: 422
    end
  end

  def login
    begin
      @user = User.find_by(username: params[:username])
      if @user && @user.authenticate(params[:password])

        # token = encode_token({ user_id: @user.id })

        token = generate_token(@user)
        @user.update!(refresh_token_digest: token[:refresh_token])
        responsePayload = {
          msg: "Login Successfully",
          id: @user.id,
          username: @user.username,
          token: token
        }

        # render json: @user.as_json(only: [:id, :username]), status: :ok
        render json: responsePayload, status: :ok
      else
        render json: { msg: "Username / Password is wrong", error: "Invalid Credentials" }, status: 422
      end
    rescue => e
      render json: { msg: e }, status: 500
    end
  end

  private

  def permit_params
    params.permit(:username, :password)
  end
end
