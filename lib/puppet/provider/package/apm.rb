require 'puppet/provider/package'
require 'json'

Puppet::Type.type(:package).provide :apm, :parent => Puppet::Provider::Package do
  desc "apm is the package manager for Atom IDE."

  has_feature :installable
  has_feature :uninstallable
  has_feature :install_options
  has_feature :uninstall_options
  has_feature :versionable

  CUSTOM_ENVIRONMENT = {"HOME" => '/home/james', "USER" => 'james'}

  if respond_to? :has_command
    has_command :apm, "apm" do
      is_optional

    end
  else
    commands :apm => "apm"
  end

  def self.parse(line)
    if line.chomp =~ /^(\S+)@(.+)/
      {:ensure => $2, :name => $1, :provider => name}
    else
      nil
    end
  end

  def self.instances
    packages = []
    process = execute "#{command :apm} list --installed --bare",
                      :custom_environment => CUSTOM_ENVIRONMENT
    process.each_line do |line|
      next unless options = parse(line)
      packages << new(options)
    end

    packages
  end

  def query
    execute "#{command :apm} list --installed --bare",
            :custom_environment => CUSTOM_ENVIRONMENT do |process|
              process.each do |line|
                options = self.class.parse(line)
                return options if options[:name] == @resource[:name]
              end
            end

    nil
  end

  def apm_command(command_str)
    self.class.apm_command(command_str)
  end

  def self.apm_command(command_str)
    execute "#{command :apm} #{command_str}", :custom_environment => CUSTOM_ENVIRONMENT
  end

  def latest
    json = JSON.parse(apm_command " outdated --json")
    item = json.select { |item| item["name"] == resource[:name] }.first

    if !item.nil?
      item["latestVersion"]
    else
      @property_hash[:ensure] unless @property_hash[:ensure].is_a? Symbol
    end
  end

  def install
    case @resource[:ensure]
      when String
        apm_command "install #{@resource[:name]}@#{@resource[:ensure]}"
      else
        apm_command "install #{@resource[:name]}"
    end
  end

  def update
    install
  end

  def uninstall
    apm_command "uninstall #{@resource[:name]}"
  end
end
