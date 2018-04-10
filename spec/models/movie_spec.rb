require 'rails_helper'

#RSpec.describe Movie, type: :model do
#  pending "add some examples to (or delete) #{__FILE__}"
#end

RSpec.describe Movie, elasticsearch: true, :type => :model do
  it 'should be indexed' do
    # create an instance of your model
    Movie.create(title: 'Tom & Jerry')

    # refresh the index
    Movie.import
    Movie.__elasticsearch__.refresh_index!

    # verify your model was indexed
    expect(Movie.search('Tom & Jerry').records.length).to eq(1)
  end

  describe 'ElasticSearch Index' do
    let(:movie_index_properties) { Movie.__elasticsearch__.mappings.as_json[:movie][:properties] }

    it "should index title as text" do
      expect(movie_index_properties[:title]).to eq({analyzer: "english",type: "text"})
    end

    it "should index overview as text" do
      expect(movie_index_properties[:overview]).to eq({analyzer: "english", type: "text"})
    end

    it "should index vote_average as float" do
      expect(movie_index_properties[:vote_average]).to eq({type: "float"})
    end
  end

  describe '.custom_search(text, filters)' do
    subject { search_results.records.map(&:title) }
    let(:search_results) {Movie.custom_search(query, filters)}
    let(:query) { "" }
    let(:filters) {}

    before(:each) do
      Movie.create(
        title: "Tom & Jerry",
        overview: "Tom and Jerry is an American animated series of short films created in 1940 by
        William Hanna and Joseph Barbera. It centers on a rivalry between its two title characters,
        Tom, a cat, and Jerry, a mouse, and many recurring characters, based around slapstick comedy.
        (Wikipedia)",
        vote_average: 4.5
      )

      Movie.create(
        title: "The Simpsons",
        overview: "The Simpsons is an American animated sitcom created by Matt Groening for the Fox
        Broadcasting Company.[1][2][3] The series is a satirical depiction of working-class life,
        epitomized by the Simpson family, which consists of Homer, Marge, Bart, Lisa, and Maggie.
        The show is set in the fictional town of Springfield and parodies American culture and society,
        television, and the human condition.
        (Wikipedia)",
        vote_average: 4.6
      )

      Movie.create(
        title: "Die Sendung mit der Maus",
        overview: "Die Sendung mit der Maus (The Show with the Mouse) is a highly acclaimed children's
        series on German television that has been called 'the school of the nation'.
        (Wikipedia)",
        vote_average: 4.2
      )

      Movie.import
      Movie.__elasticsearch__.refresh_index!
    end

    describe 'textsearch' do
      let(:query) { "Simpsons" }
      it "should include title" do
        expect(subject).to include("The Simpsons")
      end

      let(:query) { "Homer" }
      it "should include overview" do
        expect(subject).to include("The Simpsons")
      end
    end

    describe "filters" do
      describe "by vote_average" do
        let(:filters) { {vote_average: {gt: 4.5} } }
        it "should include movies with average vote greater than 4.5" do
          expect(subject).to include("The Simpsons")
        end

        it "should not include movies with average vote lower or equal to 4.5" do
          expect(subject).not_to include("Tom & Jerry")
        end
      end
    end
  end
end
