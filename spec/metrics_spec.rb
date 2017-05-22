require 'spec_helper'

describe UpdateRepo::Metrics do
  subject { UpdateRepo::Metrics }

  context 'when created' do
    let(:metrics) { subject.new }
    it 'returns an instance of the Logger Class' do
      expect(metrics).to be_an_instance_of subject
    end
    it 'sets all the metrics initially to zero' do
      metrics.instance_variable_get('@metrics').each do |_key, value|
        expect(value).to be 0 unless value.instance_of? Array
      end
    end
    it 'except for failed_list which should be an array' do
      expect(metrics[:failed_list]).to be_an(Array)
    end
  end
  context 'in use' do
    let(:metrics) { subject.new }
    it 'correctly sets and reads the numeric metric variables' do
      metrics.instance_variable_get('@metrics').each do |key, value|
        next if value.instance_of? Array
        metrics[key] = 1
        expect(metrics[key]).to eq 1
        expect(metrics[key]).not_to eq 6
      end
    end
    it 'correctly sets and reads the array metric variable' do
    end
  end
end
