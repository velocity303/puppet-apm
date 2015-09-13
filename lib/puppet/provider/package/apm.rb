require 'puppet/provider/package'
require 'json'

Puppet::Type.type(:package).provide :apm, :parent => Puppet::Provider::Package do
  desc "apm is the package manager for Atom IDE."
  CUSTOM_ENVIRONMENT = {"HOME" => ENV["HOME"], "USER" => ENV["USER"]}

  has_feature :installable, :uninstallable,
              :upgradeable, :versionable

  if respond_to? :has_command
    has_command :apm, "apm" do

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
    execpipe "#{command :apm} list --installed --bare",
             :custom_environment => CUSTOM_ENVIRONMENT do |process|
               process.collect do |line|
                 next unless options = parse(line)
                 packages << new(options)
               end
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
    item = json.select{|item| item["name"] == resource[:name]}.first

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
