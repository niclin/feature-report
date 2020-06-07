require "grape"
require "rest-client"

module App
  class Hook < Grape::API
    prefix :api
    version 'v0', using: :path
    format :json

    post "feature_report" do
      begin
        labels = params["pull_request"]["labels"].map { |label| label[:name] }

        return if !params["pull_request"]["merged"] || labels.include?("skip_notify")

        label_first = labels.first

        human_label = case label_first
                      when "enhancement"
                        "優化"
                      when "bug"
                        "修正"
                      else
                        "功能"
                      end

        payload = {
          type: human_label,
          title: params["pull_request"]["title"],
          author: params["pull_request"]["user"]["login"],
          merged_at: params["pull_request"]["merged_at"]
        }

        RestClient.post(ENV["GOOGLE_SHEET_API"], payload)
      rescue => error
        "ERROR: RESAON: #{error}"
      end
    end
  end
end