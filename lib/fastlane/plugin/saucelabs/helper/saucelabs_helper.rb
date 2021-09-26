require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class SaucelabsHelper
      # class methods that you define here become available in your action
      # as `Helper::SaucelabsHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the saucelabs plugin helper!")
      end

      # basic utility method to upload a file and set a description,
      def self.upload(payload:, app_name:, app_description:, user_name:, api_key:, region:)
        http = SauceHttp.new(UI, user_name, api_key, region)
        begin
          # http.is_available
          http.is_access_authorized
          size = File.size(payload).to_s
          payload_data = File.open(payload, "rb")
          return http.upload(app_name, app_description, payload_data, size)
        rescue => exception
          raise exception.to_s
        end
      end

      # basic utility method to check file types that Sauce Labs will accept,
      def self.file_extname(formats, path)
        formats.each do |suffix|
          return suffix if path.to_s.downcase.end_with? suffix.downcase
        end
      end
    end
  end
end
