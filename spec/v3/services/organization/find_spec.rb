require 'spec_helper'

describe Travis::API::V3::Services::Organization::Find do
  let(:org) { Organization.new(login: 'example-org') }
  before    { org.save!                              }
  after     { org.delete                             }

  describe 'existing org, public api' do
    before  { get("/v3/org/#{org.id}")       }
    example { expect(last_response).to be_ok }
    example { expect(JSON.load(body)).to be == {
      "@type"     => "organization",
      "@href"     => "/v3/org/#{org.id}",
      "id"        => org.id,
      "login"     => "example-org",
      "name"      => nil,
      "github_id" => nil
    }}
  end
end
