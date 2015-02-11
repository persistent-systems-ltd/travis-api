require 'spec_helper'
require 'sentry-raven'

class FixRaven < Struct.new(:app)
  def call(env)
    requested_at = env['requested_at']
    env['requested_at'] = env['requested_at'].to_s if env.key?('requested_at')
    app.call(env)
  rescue Exception => e
    env['requested_at'] = requested_at
    raise e
  end
end

describe 'Exception' do
  before do
    set_app Raven::Rack.new(FixRaven.new(app))
    Raven.configure do |config|
      config.async = Travis::Api::App.method(:handle_exception)
    end
  end

  it 'enques error into sidekiq' do
    exception = StandardError.new('Konstantin broke all the thingz!')
    Travis::Api::App::Endpoint::Repos.any_instance.stubs(:service).raises(exception)
    # Travis::Sidekiq::ExceptionHandler.expects(:perform_async).with()
    #expect { get "/repos" }.to raise_error
    get "/repos"
  end
end
