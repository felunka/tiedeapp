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
    tree_data = Rails.cache.fetch("tree_data") do
      root = Member.order(:date_of_birth).first
      render_tree_data(root)
    end

    respond_to do |format|
      format.json do
        render json: tree_data
      end
    end
  end
end
