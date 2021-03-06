module Travis::API::V3
  class Queries::Repository < Query
    params :id

    def find
      return Models::Repository.find_by_id(id) if id
      raise WrongParams, 'missing repository.id'.freeze
    end
  end
end
