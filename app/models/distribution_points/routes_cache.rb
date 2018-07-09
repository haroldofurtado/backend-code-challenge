# frozen_string_literal: true

module DistributionPoints
  class RoutesCache
    KEY = 'distribution-points:routes'

    private_constant :KEY

    def initialize(cache)
      @cache = cache
      @model = ::DistributionPoint
    end

    def read
      unless exist?
        routes = fetch_canonical_data.presence
        @cache.write(KEY, routes) unless routes.nil?
      end

      @cache.read(KEY)
    end

    def delete
      @cache.delete(KEY)
    end

    def exist?
      @cache.exist?(KEY)
    end

    private

    def fetch_canonical_data
      @model.pluck(:origin, :destination, :distance)
    end
  end
end
