class UsersController < ApplicationController
  respond_to :json

  def search
    respond_with User::Operation::Search[params]
    # render json: [{"label"=>"mylabel","value"=>"myvalue"}]
  end
end
