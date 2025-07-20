class AuthController < ApplicationController
  def index
    @users = User.all
    render json: @users.as_json(only: [ :id, :username ])
  end

  def signup
    puts "params >>>>>#{permit_params}"
    # render plain: "Send"
    @user = User.new(permit_params)
    if @user.save
      render json: @user.as_json(only: [ :id, :username ]), status: :created
    else
      render json: @user.errors.full_messages, status: 422
    end
  end

  def login
    begin
      @user = User.find_by(username: params[:username])
      if @user && @user.authenticate(params[:password])
        render json: @user.as_json(only: [ :id, :username ]), status: :ok
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
