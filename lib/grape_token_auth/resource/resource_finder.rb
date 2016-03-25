module GrapeTokenAuth
  class ResourceFinder
    def initialize(scope, params)
      @scope = scope
      @params = params
      set_resource_class
      set_finder_key
    end

    def self.find(scope, params)
      new(scope, params).find_resource
    end

    def find_resource
      return unless finder_key
      find_resource_by_key
    end

    private

    attr_reader :scope, :params, :resource_class, :finder_key

    def set_finder_key
      auth_keys = configuration.authentication_keys
      @finder_key = (params.keys.map(&:to_sym) & auth_keys).first
    end

    def find_resource_by_key
      query_value = params[finder_key] || params[finder_key.to_s]

      insensitive_keys = resource_class.case_insensitive_keys
      if insensitive_keys && insensitive_keys.include?(finder_key)
        query_value.downcase!
      end

      resource_class.find_by(finder_key => query_value)
    end

    def configuration
      GrapeTokenAuth.configuration
    end

    def set_resource_class
      @resource_class = configuration.scope_to_class(scope)
      fail(ScopeUndefinedError.new(scope)) unless resource_class
    end
  end
end
