class CreateMovies < ActiveRecord::Migration[5.1]
  def change
    create_table :movies do |t|
      t.string :title
      t.text :overview
      t.string :image_path
      t.date :release_date
      t.integer :revenue
      t.float :runtime
      t.float :vote_average
      t.integer :vote_count
      t.string :imdb_id

      t.timestamps
    end
  end
end
