require 'spec_helper'
describe 'repomanager' do

  context 'with defaults for all parameters' do
    it { should contain_class('repomanager') }
  end
end
