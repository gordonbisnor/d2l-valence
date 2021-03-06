module D2L
  module Valence
    # == AppContext
    # Class with contextual detail for the application (the ruby client)
    class AppContext
      APP_ID_PARAM = 'x_a'.freeze
      AUTH_KEY_PARAM = 'x_b'.freeze
      CALLBACK_URL_PARAM = 'x_target'.freeze
      AUTH_SERVICE_URI_PATH = '/d2l/auth/api/token'.freeze

      attr_reader :brightspace_host,
                  :app_id,
                  :app_key,
                  :api_version

      # @param [Valence::Host] brightspace_host Authenticating D2L Brightspace Instance
      # @param [String] app_id Application ID provided by your D2L admin
      # @param [String] app_key Application Key provided by your D2L admin
      # @param [String] api_version Version of the Valence API is use
      def initialize(brightspace_host:, app_id:, app_key:, api_version: '1.0')
        @brightspace_host = brightspace_host
        @app_id = app_id
        @app_key = app_key
        @api_version = api_version
      end

      # Generates a URL for authentication
      #
      # @param [URI::Generic] callback_uri URI to redirect to post authentication
      # @return [String] URL for authentication
      def auth_url(callback_uri)
        uri = URI(@brightspace_host)
        uri.path = AUTH_SERVICE_URI_PATH
        uri.query = query_params_using(callback_url: callback_uri.to_s)
        uri.to_s
      end

      private

      def query_params_using(callback_url:)
        {
          APP_ID_PARAM => @app_id,
          AUTH_KEY_PARAM => Encrypt.generate_from(@app_key, callback_url),
          CALLBACK_URL_PARAM => CGI.escape(callback_url)
        }.map { |p, v| "#{p}=#{v}" }.join('&')
      end
    end
  end
end
