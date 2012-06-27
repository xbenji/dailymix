class Song < ActiveRecord::Base
  belongs_to :playlist
  attr_accessible :album, :artist, :date, :name, :uri
end
