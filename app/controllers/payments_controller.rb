class PaymentsController < ApplicationController

  def index
    @member = Member.find_by params.permit(:id)
  end

  def new

  end

  def create

  end
end
