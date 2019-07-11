# before
$ rails generate scaffold Album title:string artist:string
$ rails generate scaffold Song title:string genre:string
$ rails generate migration add_album_id_to_songs album_id:integer

class Album < ActiveRecord::Base
  has_many :songs
end

class Song < ActiveRecord::Base
  belongs_to :album
end

# after
MyApp::Application.routes do
  resources :albums do
    resources :songs
  end
end


# after
# $ rake routes | grep song

class SongsController < ApplicationController
  before_filter :grab_album_from_album_id

  def index
    @songs = songs.all
  end

  def show
    @song = songs.find(params[:id])
  end

  def new
    @song = songs.new
  end

  def edit
    @song = songs.find(params[:id])
  end

  def create
    @song = songs.new(params[:song])
    if @song.save
      redirect_to(@song,
                  :notice => 'Song was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @song = songs.find(params[:id])
    if @song.update_attributes(params[:song])
      redirect_to(@song,
                  :notice => 'Song was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    Song.find(params[:id]).destroy
    redirect_to(songs_url)
  end

  private

  def songs
    @album ? @album.songs : Song
  end

  def grab_album_from_album_id
    @album = Album.find(params[:album_id]) if params[:album_id]
  end
end