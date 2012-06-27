class Playlist < ActiveRecord::Base
  attr_accessible :name, :uri, :user
  has_many :songs
  
  def self.find_latest(nb_days)
 	Playlist.find(:all, :include => [:songs], 
				:conditions => ['date(songs.date) > ?', (Time.now.midnight - nb_days.day)])
  end
  
  def self.all_with_songs
  	Playlist.find(:all, :include => [:songs])
  end
  	
end
