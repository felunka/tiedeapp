class AlbumsController < ApplicationController
  before_action :require_admin, only: %i[new create edit update destroy]

  def index
    @albums = Album.includes(:event, album_pictures: { data_attachment: :blob }).order(created_at: :desc)
  end

  def show
    @album = Album.includes(:event, album_pictures: { data_attachment: :blob }).find(params[:id])
    @album_picture = AlbumPicture.new(album: @album)
  end

  def new
    @album = Album.new
  end

  def create
    @album = Album.new permit(params)

    respond_to do |format|
      if @album.save
        flash[:success] = t('messages.model.created')
        format.html { redirect_to albums_path }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @album = Album.find(params[:id])
  end

  def update
    @album = Album.find(params[:id])

    respond_to do |format|
      if @album.update permit(params)
        flash[:success] = t('messages.model.updated')
        format.html { redirect_to albums_path }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    Album.find(params[:id]).destroy
    flash[:danger] = t('messages.model.deleted')
    redirect_to albums_path
  end

  private

  def permit(params)
    params.require(:album).permit(:name, :description, :event_id)
  end
end
