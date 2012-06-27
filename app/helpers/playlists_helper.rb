module PlaylistsHelper
	def join_tracks_id(pl)
 		pl.songs.each.map { |song| song.uri.split(':')[2] }.join(",")
  	end
end
