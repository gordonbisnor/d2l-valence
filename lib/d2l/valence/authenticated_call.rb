module D2L
  module Valence
    # == AuthenticatedCall
    # Class for authenticated calls to the D2L Valence API
    class AuthenticatedCall
      attr_reader :user_context,
                  :http_method

      #
      # == API routes
      # See D2L::Valence::UserContext.api_call for details on creating routes and route_params
      #
      # @param [D2L::Valance::UserContext] user_context the user context created after authentication
      # @param [String] http_method the HTTP Method for the call (i.e. PUT, GET, POST, DELETE)
      # @param [String] route the API method route (e.g. /d2l/api/lp/:version/users/whoami)
      # @param [Hash] route_params the parameters for the API method route (option)
      # @param [Hash] query_params the query parameters for the method call
      def initialize(user_context:, http_method:, route:, route_params: {}, query_params: {})
        @user_context = user_context
        @app_context = user_context.app_context
        @http_method = http_method.upcase
        @route = route.downcase
        @route_params = route_params
        @query_params = query_params
      end

      # Generates an authenticated URI for a the Valence API method
      #
      # @return [URI::Generic] URI for the authenticated methof call
      def to_uri
        @app_context.brightspace_host.to_uri(
          path: path,
          query: query
        )
      end

      # Actions the authenticted call on the Valence API
      #
      # @return [D2L::Valence::Response] URI for the authenticated methof call
      def execute

      end

      # Generates the final path for the authenticated call
      #
      # @return [String] path for the authenticated call
      def path
        return @path unless @path.nil?

        substitute_keys_with(known_params)
        substitute_keys_with(@route_params)
        @path = @route
      end

      private

      def substitute_keys_with(params)
        params.each { |param, value| @route.gsub!(":#{param}", value.to_s) }
      end

      def known_params
        {
          version: @user_context.app_context.api_version
        }
      end

      def query
        @query_params.merge(authenticated_tokens).map { |k, v| "#{k}=#{v}" }.join('&')
      end

      def authenticated_tokens
        D2L::Valence::AuthTokens.new(call: self).generate
      end
    end
  end
end