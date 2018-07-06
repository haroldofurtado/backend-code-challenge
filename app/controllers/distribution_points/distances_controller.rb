# frozen_string_literal: true

module DistributionPoints
  class DistancesController < ApplicationController
    def create
      result = DeserializeAndSave.new.call(request.body.read)
      status = result.success? ? :no_content : :bad_request

      render status: status, nothing: true
    end
  end
end
