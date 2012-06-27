class PlaylistsController < ApplicationController
	def index
	  @playlists = case params[:when]
	  	when "all" then Playlist.all_with_songs
	  	when "today" then Playlist.find_latest(0)
	  	when "24" then Playlist.find_latest(1)
	  	when "48" then Playlist.find_latest(2)
	 	else Playlist.all
	 	end
	 	
	  respond_to do |format|
		format.html  # index.html.erb
		format.json  { render :json => @playlists, :include => [:songs] }
	  end
	end
end
