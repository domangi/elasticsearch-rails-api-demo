require "csv"

movie_hashes = []
# movies_metadata.csv as part of kaggle dataset https://www.kaggle.com/rounakbanik/the-movies-dataset
# Data is collected from TMDB. To access the image specified in image_path use tmdb Api
# For example the image path "/3A0UjhIMqWivqtq5mXhidBaSZGg.jpg" can be used to retrieve
# a 600x900 image at the following url
# => "https://image.tmdb.org/t/p/w600_and_h900_bestv2/3A0UjhIMqWivqtq5mXhidBaSZGg.jpg"
CSV.foreach(Rails.root.join("data/movies_metadata.csv"), { :headers => true }) do |csv|
  title, overview, image_path, release_date, revenue,
    runtime, vote_average, vote_count, imdb_id =
    csv[20], csv[9], csv[11], csv[14], csv[16], csv[15],
    csv[22], csv[23], csv[6]

  movie_hashes << {
    imdb_id: imdb_id,
    title: title,
    overview: overview,
    image_path: image_path,
    release_date: release_date,
    revenue: revenue,
    runtime: runtime,
    vote_average: vote_average,
    vote_count: vote_count
  }
end

# remove existing movies to avoid duplications
imdb_ids = movie_hashes.collect{|movie| movie[:imdb_id]}
puts "importing #{imdb_ids.size} movies"
Movie.where(imdb_id: imdb_ids).delete_all
# bulk insert all movies in csv
Movie.bulk_insert values: movie_hashes
puts "Movies in database: #{Movie.count}"
Movie.import
