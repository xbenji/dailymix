require 'hallon'
#require 'rake'

namespace :admin do
	
	desc "test"
	task :addsong => :environment do
		song = Song.new(:name => "test track")
		song.save
  end

  desc "Update recent songs base since last update"
  task :auto_update  => :environment do |t, args|
    $nb_seconds = 4*60*60
    p = Playlist.first
    if p
      $nb_seconds = Time.now - p.created_at
    end
    puts "Updating song base with songs from last #{$nb_seconds} seconds (#{$nb_seconds/3600} hours)"
    #load 'dailyspoti.rb'
  end

	desc "Update recent songs base" 
	task :update, [:nb_hours] => :environment do |t, args|
		$nb_seconds = args[:nb_hours].to_i*60*60
		puts "Updating song base with songs from last #{$nb_seconds} seconds"
		load 'dailyspoti.rb'
	end

end


