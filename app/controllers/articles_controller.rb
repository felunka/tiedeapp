class ArticlesController < ApplicationController
  before_action :load_article_collection
  before_action :load_article, only: %i[show edit update destroy]
  before_action :require_owner_or_admin, only: %i[edit update destroy]

  def show
  end

  def new
    @article = @article_collection.articles.new
  end

  def create
    @article = @article_collection.articles.new permit(params)
    @article.author = current_user

    respond_to do |format|
      if @article.save
        flash[:success] = t('messages.model.created')
        format.html { redirect_to article_collection_article_path(@article_collection, @article) }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @article.update permit(params)
        flash[:success] = t('messages.model.updated')
        format.html { redirect_to article_collection_article_path(@article_collection, @article) }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @article.destroy
    flash[:danger] = t('messages.model.deleted')
    redirect_to article_collection_path(@article_collection)
  end

  private

  def load_article_collection
    @article_collection = ArticleCollection.find(params[:article_collection_id])
  end

  def load_article
    @article = @article_collection.articles.includes(author: :member).find(params[:id])
  end

  def require_owner_or_admin
    return if current_user.admin? || @article.author_id == current_user.id

    raise ApplicationController::NotAuthorized
  end

  def permit(params)
    params.require(:article).permit(:title, :content)
  end
end
