class ArticleCollectionsController < ApplicationController
  before_action :require_admin, only: %i[new create edit update destroy]

  def index
    @article_collections = ArticleCollection.order(created_at: :desc)
  end

  def show
    @article_collection = ArticleCollection.includes(articles: { author: :member }).find(params[:id])
  end

  def new
    @article_collection = ArticleCollection.new
  end

  def create
    @article_collection = ArticleCollection.new permit(params)

    respond_to do |format|
      if @article_collection.save
        flash[:success] = t('messages.model.created')
        format.html { redirect_to article_collections_path }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @article_collection = ArticleCollection.find(params[:id])
  end

  def update
    @article_collection = ArticleCollection.find(params[:id])

    respond_to do |format|
      if @article_collection.update permit(params)
        flash[:success] = t('messages.model.updated')
        format.html { redirect_to article_collections_path }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    ArticleCollection.find(params[:id]).destroy
    flash[:danger] = t('messages.model.deleted')
    redirect_to article_collections_path
  end

  private

  def permit(params)
    params.require(:article_collection).permit(:name, :description)
  end
end
