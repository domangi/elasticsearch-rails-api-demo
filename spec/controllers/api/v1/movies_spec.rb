require 'rails_helper'

RSpec.describe Api::V1::MoviesController, type: :request do
  # Search for movie with text movie-title and with average vote greater t
  describe "GET /api/v1/movies?search=" do
    let(:text_query) { "movie-title"}
    let(:filters) { {"vote_average": {"gt": "4.5"} }.with_indifferent_access }
    let(:url) { "/api/v1/movies?search=#{text_query}&filters%5B#{filters.to_param}"}

    it "calls Movie.custom_search with correct parameters" do
      expect(Movie).to receive(:custom_search).with(text_query, filters)
      get url
    end

    it "returns the output of Movie.custom_search" do
      Movie.create(title: "Kalimero")
      allow(Movie).to receive(:custom_search).and_return(Movie.all)
      get url
      json = JSON.parse(response.body)
      expect(json['movies'].map{|movie| movie["title"]}).to eq(["Kalimero"])
    end

    it "adds pagination to Movie.custom_search output" do
      expect(Movie).to receive_message_chain(:custom_search, :page).with(text_query, filters).with("2")
      get url+"&page=2"
    end

    it 'returns a success status' do
      allow(Movie).to receive(:custom_search).with(text_query, filters).and_return(Movie.all)
      get url
      expect(response).to be_success
    end
  end
end
