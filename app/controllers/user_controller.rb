class UserController < ApplicationController
  before_action :authenticate_user!

  def userInfo
    id = params[:id]
    puts "The current User >>>>>.. #{@current_user.inspect}"
    begin
      user = User.find(id)
      if user.eql?(@current_user)
        user_todos = user.todos
        puts "User todo >>>>.#{user_todos}"
        response_data = {
          user: user.as_json(only: [ :id, :username ]),
          todos: user_todos.as_json(only: [ :id, :task, :status ])
        }
        render json: response_data, status: :ok
      else
        render json: { msg: "You can not access " }, status: :bad_request
      end

    rescue ActiveRecord::RecordNotFound => e
      puts "User not found #{e}"
      render json: { msg: e }, status: 422
    end

  end
end
