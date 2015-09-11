require 'spec_helper'
describe 'atom' do

  context 'with defaults for all parameters' do
    it { should contain_class('atom') }
  end
end
