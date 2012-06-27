#!/usr/bin/env ruby

require 'hallon'
require 'progressbar'

sp_login = ENV['SP_LOGIN']
sp_passwd = ENV['SP_PASSWD']

upload_playlists = false

# exclude playlists with a given pattern
Pl_excl_list = [
	/DailySpoti/,
	/dailyspoti/,
	/xbpl/,
	/nova/,
	/spotimy.co.uk/,
	/New Album Releases on Spotify/
]

# extend playlist class to add filter method
class Hallon::Playlist
	def is_excluded_playlist?
		Pl_excl_list.each do |regex|
			return true if name =~ regex
		end
		return false
	end
end

def get_nb_seconds
	if defined? Rake
		$nb_seconds # is set in the rake task
	else
		60*60*4
	end
end

total_tracks_count = 0
recent_tracks_count = 0

# -- Initialize and get connected
session = Hallon::Session.initialize(IO.read('spotify_appkey.key'), { :tracefile => nil })
session.login!(sp_login, sp_passwd)

# -- Get all the playlists
puts " * Logged as #{sp_login}, get playlists"
container = session.container.load

all_playlists = container.contents.find_all do |playlist|
	playlist.is_a?(Hallon::Playlist) # ignore folders
end

# -- ask them to load (should specify a timout here)
total = all_playlists.size
pbar = ProgressBar.new("loading", total)
puts " * Scanning #{total} playlists..."
all_playlists.each do |playlist|
	playlist.load 0
  pbar.inc
  total_tracks_count += playlist.size
end
pbar.finish

# -- Cacning all tracks, and save them if recent
pbar_songs = ProgressBar.new("loading", total_tracks_count)
puts " * Playlists loaded, scanning #{total_tracks_count} tracks..."

now = Time.now
#time_diff = 60*60*get_nb_hours.to_i
time_diff = get_nb_seconds

songs_hash = Hash.new

all_playlists.each do |playlist|
	next if playlist.is_excluded_playlist?
	playlist.tracks.each do |track|
		session.wait_for{ track.loaded? }
    pbar_songs.inc
		next unless (now - track.added_at) < time_diff
    recent_tracks_count += 1
		unless songs_hash.key?(playlist)
			songs_hash[playlist] = []
		end
		  songs_hash[playlist] << track
  end
end
pbar_songs.finish

puts " * Found #{recent_tracks_count} new songs since #{now - time_diff}"
puts " * Saving to database..."

Playlist.delete_all
songs_hash.each do |playlist, tracks|
	#create playlist
	pl = Playlist.new(:name => playlist.name,
					  :uri => playlist.to_link.to_uri,
					  :user => playlist.owner.name)
	pl. save
	# save each track
	tracks.each do |track| 
		song = Song.new(:name => track.name, 
						:artist => track.artist.name, 
						:date => track.added_at, 
						:uri => track.to_link.to_uri)
		pl.songs << song
	end
end

if upload_playlists
	# save it to a new playlist
	playlist_name = "dailyspoti [#{(now - time_diff).strftime('%m/%d %I:%M')}]"
	puts "Creating playlist #{playlist_name}..."

	new_playlist = container.add playlist_name, force: true
	recent_songs.each do |track|
		new_playlist.insert(track)
	end

	puts "Playlist created, uploading to spotify..."
	new_playlist.upload(20)
end

puts "DONE"
