require 'rails_helper'

RSpec.describe JenkinsCiService do
  let(:server_url) { 'http://portsdown.local:8080' }
  let(:auth_key) { 'auth_key' }
  let(:project_name) { 'Concierge' }
  let(:opts) do
    {
      server_url: server_url,
      auth_key: auth_key,
      project_name: project_name
    }
  end

  subject{ JenkinsCiService.new(opts) }

  describe '#initialize' do
    it 'sets default values' do
      expect(subject.server_url).to eq server_url
      expect(subject.auth_key).to eq auth_key
      expect(subject.project_name).to eq project_name
    end
  end

  describe '.for_widget' do
    let(:dashboard) { FactoryGirl.create :dashboard }
    let(:widget){
      FactoryGirl.create :widget,
                  dashboard: dashboard,
                  category: 'ci_widget',
                  server_type: 'jenkins_ci',
                  server_url: server_url,
                  auth_key: auth_key,
                  project_name: project_name
    }

    subject{ JenkinsCiService.for_widget(widget) }

    it 'sets default values' do
      expect(subject.server_url).to eq server_url
      expect(subject.auth_key).to eq auth_key
      expect(subject.project_name).to eq project_name
    end
  end

  describe '#repo_info' do
    it 'makes request to repo' do
      mock_request = stub_request(:get, "#{server_url}/job/#{project_name}/api/json").
          with(headers: { 'Accept' => 'application/json',
                          'Authorization' => 'Token "' + auth_key + '"' }).
          to_return(body:    '{"foo":"bar"}',
                    headers: {'Content-Type' => 'application/json'})

      result = subject.repo_info

      expect(mock_request).to have_been_made
      expect(result.body["foo"]).to eq "bar"
    end
  end

  describe '#build_info' do
    let(:build_id) { 12345 }

    it 'makes request to repo' do
      mock_request = stub_request(:get, "#{server_url}/job/#{project_name}/#{build_id}/api/json").
          with(headers: { 'Accept' => 'application/json',
                          'Authorization' => 'Token "' + auth_key + '"' }).
          to_return(body:    '{"foo":"bar"}',
                    headers: {'Content-Type' => 'application/json'})

      result = subject.build_info(build_id)

      expect(mock_request).to have_been_made
      expect(result.body["foo"]).to eq "bar"
    end
  end

  describe '#last_build_info' do
    let(:build_id) { 12345 }
    let(:is_building) { false }
    let(:last_build_status) { 'success' }
    let(:last_build_time) { '2016-01-15 11:00:00 +08:00' }
    let(:last_committer) { 'Rahul Rajeev' }

    it 'makes request to repo' do
      build_response_body = {"building" => is_building, "result" => last_build_status,
                             "timestamp" => last_build_time,
                             "changeSet" => { "items" => [
                                              { "author" => { "fullName" => last_committer } }
                                            ]
                             } }.to_json
      build_request = stub_request(:get, "#{server_url}/job/#{project_name}/lastBuild/api/json").
          with(headers: { 'Accept' => 'application/json',
                          'Authorization' => 'Token "' + auth_key + '"' }).
          to_return(body: build_response_body,
                    headers: {'Content-Type' => 'application/json'})

      result = subject.last_build_info

      expect(build_request).to have_been_made
      expect(result.keys).to include :repo_name, :last_build_status, :last_committer, :last_build_time
      expect(result[:repo_name]).to eq project_name
      expect(result[:last_build_time]).to eq last_build_time
      expect(result[:last_build_status]).to eq last_build_status
      expect(result[:last_committer]).to eq last_committer
    end
  end
end
