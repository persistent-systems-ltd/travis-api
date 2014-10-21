require 'multi_json'
require 'travis/sidekiq/build_request'
require 'travis/services/base'

class Travis::Api::App
  module Services
    class ScheduleRequest < Travis::Services::Base
      MESSAGES = {
        success:   { notice: 'Build request scheduled.' },
        not_found: { error: 'Repository not found.' },
        forbidden: { error: 'Forbidden.' }
      }

      register :schedule_request

      attr_reader :result

      def run
        schedule_request if validate
        result
      end

      def messages
        [MESSAGES[result]]
      end

      private

        def validate
          if !repo
            @result = :not_found
          elsif !active?
            @result = :not_found
          elsif !permission?
            @result = :forbidden
          end
          !@result
        end

        def schedule_request
          Metriks.meter('api.request.create').mark
          Travis::Sidekiq::BuildRequest.perform_async(type: 'api', payload: payload, credentials: {})
          @result = :success
        end

        def not_found
          :not_found
        end

        def active?
          Travis::Features.owner_active?(:request_create, repo.owner)
        end

        def permission?
          current_user.permission?(:push, repository_id: repo.id)
        end

        def payload
          data = params.merge(user: { id: current_user.id })
          data[:repository][:id] = repo.github_id
          MultiJson.encode(data)
        end

        def repo
          @repo ||= Repository.by_slug(slug).first
        end

        def slug
          repo = params[:repository] || {}
          repo.values_at(:owner_name, :name).join('/')
        end
    end
  end
end
