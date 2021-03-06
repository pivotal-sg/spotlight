require 'rails_helper'

RSpec.describe Ci::ConcourseCiBuild do
  it 'shows passed when it succeeds' do
    build_info = {
      id: '664',
      status: 'succeeded',
      start: '2016-09-16@17:31:43+0800',
      end: '2016-09-16@17:40:14+0800'
    }

    build = Ci::ConcourseCiBuild.new build_info

    expect(build.state).to eq Category::CiWidget::STATUS_PASSED
    expect(build.timestamp).to eq '2016-09-16@17:40:14+0800'
  end

  it 'shows failed when it fails' do
    build_info = {
      id: '664',
      status: 'failed',
      start: '2016-09-16@17:31:43+0800',
      end: '2016-09-16@17:40:14+0800'
    }

    build = Ci::ConcourseCiBuild.new build_info

    expect(build.state).to eq Category::CiWidget::STATUS_FAILED
    expect(build.timestamp).to eq '2016-09-16@17:40:14+0800'
  end

  context 'when the status is started' do
    let(:build_info) do
      {
          id: '664',
          status: 'started',
          start: '2016-09-16@17:31:43+0800',
          end: ''
      }
    end

    subject { Ci::ConcourseCiBuild.new build_info }

    it 'sets the state to building' do
      expect(subject.state).to eq Category::CiWidget::STATUS_BUILDING
    end

    it 'sets the timestamp to the start time' do
      expect(subject.timestamp).to eq build_info[:start]
    end

  end

end

