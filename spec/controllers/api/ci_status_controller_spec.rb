require 'rails_helper'

RSpec.describe Api::CiStatusController, type: :controller do
  let!(:user) { User.create(email: 'spotlight@pivotal.io', auth_token: 'fake-spotlight-token') }

  describe 'GET #show' do
    let(:project_name) { 'spotlight' }
    let(:basic_auth) { 'user:password' }
    let(:server_url) { "http://#{basic_auth}@portsdown.local:8080" }
    let(:auth_key) { Base64.encode64(basic_auth) }
    let(:dashboard)  { FactoryGirl.create :dashboard, title:'Default Dashboard' }
    let!(:widget) { FactoryGirl.create :widget,
                                       :ci_widget,
                                       project_name: project_name,
                                       server_url: server_url,
                                       server_type: 'jenkins_ci',
                                       dashboard: dashboard,
                                       auth_key: auth_key
    }

    let(:build_history_response_body) do
      { "builds" => [
          { "number" => 716, 'building' => false, "result" => "SUCCESS", "timestamp" => 1453883748620, "changeSets" => [ {"items" => [ {"author"=>{'fullName'=>'Rahul Rajeev'}} ]} ] }
      ]
      }.to_json
    end
    let!(:mock_request) do
      stub_request(:get, "#{server_url}/job/#{project_name}/api/json?tree=builds[number,building,timestamp,result,committer_name,changeSet[items[author[fullName]]],changeSets[items[author[fullName]]]]").
        with(headers: { 'Accept' => 'application/json'}).
        to_return(body:    build_history_response_body,
                  headers: {'Content-Type' => 'application/json'})
    end

    before do
      request.headers['X-Spotlight-Token'] = 'fake-spotlight-token'
      get :show, id: widget.uuid, format: :json
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns the ci_status' do
      ci_status = assigns(:ci_status)
      expect(ci_status[:repo_name]).to eq project_name
      expect(ci_status[:build_history].first).to be_a_kind_of(Ci::JenkinsCiBuild)
    end
  end
end
