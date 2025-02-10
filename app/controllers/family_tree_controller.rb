class FamilyTreeController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:import]
  include FamilyTreeHelper

  def show; end

  def import
    ActiveRecord::Base.transaction do
      process_member(params[:treeData])
    end
  end

  def data
    root = Member.order(:date_of_birth).first

    respond_to do |format|
      format.json do
        render json: render_tree_data(root)
      end
    end
  end
end
