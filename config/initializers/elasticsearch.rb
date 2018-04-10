# frozen_string_literal: true

config = {
  transport_options: {
    request: { timeout: 300 }
  },
  log: false, trace: false
}

if File.exists?("config/elasticsearch.yml")
 config.merge!(YAML.load_file("config/elasticsearch.yml")[Rails.env].symbolize_keys)
end

Elasticsearch::Model.client = Elasticsearch::Client.new(config)

