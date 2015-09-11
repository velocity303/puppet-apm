#!/usr/bin/env rspec
require 'spec_helper'

describe Puppet::Type.type(:package).provider(:apm) do
  before :each do
    @resource =  Puppet::Type.type(:package).new(
      :name   => 'language-puppet',
      :ensure => :present
    )
    @provider = described_class.new(@resource)
    @provider.class.stubs(:optional_commands).with(:apm).returns "/usr/local/bin/apm"
    @provider.class.stubs(:command).with(:apm).returns "/usr/local/bin/apm"
  end

  def self.it_should_respond_to(*actions)
    actions.each do |action|
      it "should respond to :#{action}" do
        expect(@provider).to respond_to(action)
      end
    end
  end

  it_should_respond_to :install, :uninstall, :update, :query, :latest

  describe 'instances' do
    it 'should return instances correctly' do

    end
  end
end
