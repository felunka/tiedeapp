class AlbumPicturesController < ApplicationController
  before_action :require_admin, only: %i[destroy]

  def create
    @album = Album.find(params[:album_id])
    files = Array(album_picture_params[:data]).reject(&:blank?)

    return redirect_to album_path(@album), flash: { warning: t('albums.errors.no_file_selected') } if files.blank?

    Album.transaction do
      files.each do |file|
        picture = @album.album_pictures.new(description: album_picture_params[:description])
        picture.data.attach(file)
        picture.save!
      end
    end

    flash[:success] = t('messages.model.created')
    redirect_to album_path(@album)
  end

  def update
    album_picture = AlbumPicture.find(params[:id])

    if album_picture.update(album_picture_params)
      flash[:success] = t('messages.model.updated')
    else
      flash[:danger] = t('messages.model.updated')
    end

    redirect_to album_path(album_picture.album)
  end

  def destroy
    album_picture = AlbumPicture.find(params[:id])
    album = album_picture.album
    album_picture.destroy
    flash[:danger] = t('messages.model.deleted')
    redirect_to album_path(album)
  end

  private

  def album_picture_params
    params.require(:album_picture).permit(:description, data: [])
  end
end
