class CreatePlaylists < ActiveRecord::Migration
  def change
    create_table :playlists do |t|
      t.string :name
      t.string :user
      t.string :uri

      t.timestamps
    end
  end
end
