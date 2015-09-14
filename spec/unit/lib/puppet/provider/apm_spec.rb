require 'spec_helper'

describe Puppet::Type.type(:package).provider(:apm) do
  let (:name) { 'language-puppet' }
  let (:resource) { Puppet::Type.type(:package).new(:name => name, :provider => :apm) }
  let (:provider) { resource.provider }

  before :each do
    create_stubbed_provider
  end

  describe 'provider features' do
    it { is_expected.to be_installable }
    it { is_expected.to be_uninstallable }
    it { is_expected.to be_install_options }
    it { is_expected.to be_uninstall_options }
    it { is_expected.to be_versionable }
  end

  def create_stubbed_provider(params = {})
    new_resource params
    new_provider
    stub_provider
  end

  def new_resource(hash = {})
    params = {:name => 'language-puppet', :ensure => :present, :provider => :apm}.merge(hash)
    @resource = Puppet::Type.type(:package).new(params)
  end

  def new_provider
    @provider = described_class.new(@resource)
  end

  def stub_provider
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

  describe 'uninstall' do
    it 'should call apm_command' do
      @provider.class.stubs(:apm_command).with("uninstall language-puppet")
      @provider.uninstall
    end
  end

  describe 'install' do
    it 'should call apm_command without version' do
      @provider.class.stubs(:apm_command).with("install language-puppet")
      @provider.install
    end
    it 'should call apm_command with version' do
      new_resource :ensure => '0.14.0'
      new_provider
      stub_provider
      @provider.class.stubs(:apm_command).with("install language-puppet@0.14.0")
      @provider.install
    end
  end
end
