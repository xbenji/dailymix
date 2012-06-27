class SongsController < ApplicationController
	def index
	  @songs = Song.all
	 
	  respond_to do |format|
		format.html  # index.html.erb
		format.json  { render :json => @posts }
	  end
	end
end
