class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|
      t.string :name
      t.string :artist
      t.string :album
      t.string :uri
      t.timestamp :date
      t.references :playlist

      t.timestamps
    end
    add_index :songs, :playlist_id
  end
end
