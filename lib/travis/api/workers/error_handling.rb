require 'sidekiq/worker'


module Travis
  module Sidekiq
    class ErrorHandling

      include ::Sidekiq::Worker
      sidekiq_options queue: :error_handling

      def perform(data)
      end

    end
  end
end
#
#receive the payload
#generate the auth_header

#data = JSON.load(payload)

# begin
#   transport.send(auth_header, data['encoded_data'], :content_type => data['content_type'])
#   rescue => e
#     failed_send(e, event)
#     return
#   end

#   successful_send

#   event
# end
