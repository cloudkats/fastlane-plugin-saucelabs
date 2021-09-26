require 'fastlane/action'
require_relative '../helper/saucelabs_helper'

module Fastlane
  module Actions

    module SharedValues
      SAUCE_USERNAME = :SAUCE_USERNAME
      SAUCE_ACCESS_KEY = :SAUCE_ACCESS_KEY
      SAUCE_REGION = :SAUCE_REGION
      SAUCE_ITEM_NAME = :SAUCE_ITEM_NAME
      SAUCE_ITEM_KIND = :SAUCE_ITEM_KIND
      SAUCE_ITEM_ID = :SAUCE_ITEM_ID
      SAUCE_ITEM_SIZE = :SAUCE_ITEM_SIZE
      SAUCE_ITEM_REGION = :SAUCE_ITEM_REGION
    end

    class SaucelabsUploadAction < Action
      #noinspection RubyResolve
      def self.run(params)
        UI.message("The saucelabs plugin is working!")
        file = params[:file]
        region = params[:region]
        username = params[:user_name]
        apikey = params[:api_key]
        app_name = params[:app_name]
        app_description = params[:app_description]

        if file.to_s.length == 0
          UI.user_error!("Couldn't find build file at path #{file}` ❌")
        end

        upload(payload: file,
               app_name: app_name,
               app_description: app_description,
               user_name: username,
               api_key: apikey,
               region: region)
      end

      def self.upload(payload:, app_name:, app_description:, user_name:, api_key:, region:)
        UI.message("Starting \"#{app_name}\" upload to Sauce Labs...")

        begin
          result = Helper::SaucelabsHelper.upload(
            payload: payload,
            app_name: app_name,
            app_description: app_description,
            user_name: user_name,
            api_key: api_key,
            region: region)

          if result and result.is_a?(Hash)
            Actions.lane_context[SharedValues::SAUCE_ITEM_NAME] = result[:name] if result.has_key?(:name)
            Actions.lane_context[SharedValues::SAUCE_ITEM_KIND] = result[:kind] if result.has_key?(:kind)
            Actions.lane_context[SharedValues::SAUCE_ITEM_ID] = result[:id] if result.has_key?(:id)
            Actions.lane_context[SharedValues::SAUCE_ITEM_SIZE] = result[:size] if result.has_key?(:size)
            Actions.lane_context[SharedValues::SAUCE_ITEM_REGION] = result[:region] if result.has_key?(:region)
          end
          UI.message("Upload \"#{app_name}\" ✅")
        rescue => exception
          UI.user_error!("Failed to upload ❌. #{exception.to_s}")
        end
      end

      def self.description
        "Sauce labs android & ios Fastlane plugin"
      end

      def self.authors
        ["@CloudKats https://github.com/cloudkats"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Upload ios&android artifacts to Sauce Labs https://docs.saucelabs.com/"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :file,
                                       env_name: "",
                                       description: "zip file for the upload",
                                       optional: false,
                                       type: String,
                                       verify_block: proc do |value|
                                         if value
                                           UI.user_error!("Could not find file to upload \"#{file}\" ") unless File.exist?(value) || Helper.test?
                                           accepted_formats = %w(.api .ipa)
                                           file_ext = Helper::SaucelabsHelper.file_extname(accepted_formats, value)
                                           # UI.user_error!("Extension not supported for \"#{file}\" ") unless accepted_formats.include? file_ext
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :app_name,
                                       env_name: "SAUCE_APP_NAME",
                                       description: "App name as found in the App's URL in Sauce Labs",
                                       default_value: Actions.lane_context[SharedValues::SAUCE_ITEM_NAME],
                                       optional: false,
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!("No App name given, pass using `app_name: 'app name'`") unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :app_description,
                                       description: "App description as it found in \"item.description\" Sauce Labs",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :user_name,
                                       env_name: "SAUCE_USERNAME",
                                       description: "The Sauce Labs API uses basic auth username to authenticate requests",
                                       default_value: Actions.lane_context[SharedValues::SAUCE_USERNAME],
                                       optional: false,
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!("No API username given, pass using `username: 'sauce user name'`") unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_key,
                                       env_name: "SAUCE_ACCESS_KEY",
                                       description: "The Sauce Labs API uses API keys to authenticate requests",
                                       default_value: Actions.lane_context[SharedValues::SAUCE_ACCESS_KEY],
                                       optional: false,
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!("No API key given, pass using `apikey: 'sauce access key'`") unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :region,
                                       env_name: "SAUCE_REGION",
                                       description: "Api endpoint region e.g. 'us', 'us-west-1', 'eu' or 'eu-central-1' ",
                                       default_value: Actions.lane_context[SharedValues::SAUCE_REGION],
                                       optional: false,
                                       type: String,
                                       verify_block: proc do |value|
                                         accepted_formats = %w[us us-west-1 eu-central-1 eu]
                                         UI.user_error!("Only \"us\", \"eu\", \"us-west-1\" and \"eu-central-1\", types are allowed, you provided \"#{value}\"") unless accepted_formats.include? value || Helper.test?
                                       end)
        ]
      end

      def self.output
        [
          ['SAUCE_USERNAME', 'Contains API user name'],
          ['SAUCE_REGION', 'Contains API region'],
          ['SAUCE_ITEM_NAME', 'Contains item name'],
          ['SAUCE_ITEM_SIZE', 'Contains item size'],
          ['SAUCE_ITEM_ID', 'Contains item id in uuid format'],
          ['SAUCE_ITEM_KIND', 'Contains item kind e.g., android or ios'],
          ['SAUCE_ITEM_REGION', 'Contains region where item is uploaded']
        ]
      end

      def self.example_code
        [
          'saucelabs_upload(
            user_name: "user name",
            api_key:  "api key",
            app_name: "Android.artifact.apk",
            file: "app/build/outputs/apk/debug/app-debug.apk",
            region: "eu"
          )',
          'saucelabs_upload(
            user_name: "user name",
            api_key:  "api key",
            app_name: "iOS.artifact.ipa",
            file: "app.ipa",
            description
            region: "us-west-1"
          )'
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
