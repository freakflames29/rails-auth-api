class ApplicationController < ActionController::API
  SECRET_KEY = Rails.application.credentials.secret_key_base


  def method_not_allowed
     render json: {
      error: "405 Method Not Allowed",
      message: "This endpoint only accepts POST requests"
    }, status: :method_not_allowed
  end

  def encode_token(payload, exp = 15.minutes.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)

  end

  def decode_token(token)

    begin
      decoded = JWT.decode(token, SECRET_KEY, true, algorithm: 'HS256')[0]
      puts "Decoded TOKEN >>>>>>>>>>>#{decoded}"
      decoded
    rescue JWT::DecodeError
      nil
    end

  end

  def current_user

    token = request.headers["Authorization"]
    token = token.split('Bearer ')
    token = token.last
    return nil unless token
    decodedToken = decode_token(token)
    puts "Decoded token>>>>>>>>>*-*-*-*-*-* #{decodedToken["user_id"]}"
    return nil unless decodedToken

    # todo add token purpose validity
    if decodedToken["purpose"].eql?("access")

      @current_user ||= User.find_by(id: decodedToken["user_id"])
    else
      render json: { msg: "Please provide the access token" }, status: :bad_request
    end

  rescue => e
    nil
  end

  def generate_token(user)
    a_payload = {
      user_id: user.id,
      exp: 30.minutes.from_now.to_i,
      purpose: "access"
    }
    r_payload = {
      user_id: user.id,
      exp: 30.minutes.from_now.to_i,
      purpose: "refresh"
    }

    access_token = JWT.encode(a_payload, SECRET_KEY)
    refresh_token = JWT.encode(r_payload, SECRET_KEY)

    { access_token: access_token, refresh_token: refresh_token }
  end

  def authenticate_user!
    render json: { msg: "Authentication credentials are required" }, status: :unauthorized unless current_user
  end

end
