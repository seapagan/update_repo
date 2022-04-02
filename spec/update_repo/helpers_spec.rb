# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Helpers do
  # let(:dummy_class) { TestClass.new }
  let(:dummy_class) { Class.new { extend Helpers } }

  context 'when testing the pluralize helper function' do
    it 'Correctly pluralizes multiple warnings' do
      result = dummy_class.pluralize(2, :warning)
      expect(result).to eq '2 Warnings'
    end

    it 'Does not pluralize single warnings' do
      result = dummy_class.pluralize(1, :warning)
      expect(result).to eq '1 Warning'
    end

    it 'Correctly pluralizes other multiple Metrics' do
      result = dummy_class.pluralize(5, :skipped)
      expect(result).to eq '5 Skipped'
    end

    it 'Does not pluralize other single metrics' do
      result = dummy_class.pluralize(1, :processed)
      expect(result).to eq '1 Processed'
    end
  end

  context 'when testing the trunc_dir helper function' do
    it 'Does not strip any path segments when passed 0' do
      result = dummy_class.trunc_dir('one/two/three', 0)
      expect(result).to eq 'one/two/three'
    end

    it 'Correctly strips the required path segments' do
      result = dummy_class.trunc_dir('one/two/three', 1)
      expect(result).to eq 'two/three'
    end

    it 'Returns an empty string if all segments are removed' do
      result = dummy_class.trunc_dir('one/two/three', 3)
      expect(result).to eq ''
    end

    it 'Returns an empty string if more segments are removed than exist' do
      result = dummy_class.trunc_dir('one/two/three', 6)
      expect(result).to eq ''
    end
  end
  # pending 'Tests to be written'
end
