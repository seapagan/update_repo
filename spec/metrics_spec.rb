require 'spec_helper'

RSpec.describe UpdateRepo::Metrics, '(A Class to store & return run metrics)' do
  subject { UpdateRepo::Metrics }

  context 'when created' do
    let(:metrics) { subject.new }
    it 'returns an instance of the Metrics Class' do
      expect(metrics).to be_an_instance_of subject
    end
    it 'sets all the numeric metrics initially to zero' do
      metrics.instance_variable_get('@metrics').each do |_key, value|
        expect(value).to be 0 unless value.instance_of? Array
      end
    end
    it 'sets failed_list to a blank array' do
      expect(metrics[:failed_list]).to eq([])
    end
  end
  context 'in use' do
    let(:metrics) { subject.new }
    it 'correctly sets and reads the numeric metric variables' do
      metrics.instance_variable_get('@metrics').each do |key, value|
        next unless value.instance_of? Integer
        metrics[key] = 1
        expect(metrics[key]).to eq 1
      end
    end
    it 'correctly sets and reads the array metric variables' do
      metrics.instance_variable_get('@metrics').each do |key, value|
        next unless value.instance_of? Array
        metrics[key] = %w[one two]
        expect(metrics[key]).to eq %w[one two]
        expect(metrics[key].length).to eq 2
      end
    end
  end
end
