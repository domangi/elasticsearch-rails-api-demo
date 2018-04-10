require 'elasticsearch/dsl'

class Movie < ApplicationRecord
  include Elasticsearch::Model

  # ElasticSearch Index
  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :title, analyzer: 'english'
      indexes :overview, analyzer: 'english'
      indexes :vote_average, type: 'float'
    end
  end

  def self.custom_search(text, filters)
    query = Elasticsearch::DSL::Search.search do
      query do
        bool do
          must do
            if text.blank?
              match_all {}
            else
              multi_match do
                query text
                fields [:title, :overview]
                type "most_fields"
              end
            end
          end # end must

          # VOTE AVERAGE FILTER
          if filters && filters[:vote_average]
            filter do
              range vote_average: filters[:vote_average]
            end
          end
        end
      end
    end

    search query
  end
end
