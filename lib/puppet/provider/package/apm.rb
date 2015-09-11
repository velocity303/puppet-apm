require 'puppet/provider/package'

Puppet::Type.type(:package).provide :apm, :parent => Puppet::Provider::Package do
  desc "apm is the package manager for Atom IDE."
  CUSTOM_ENVIRONMENT = {"HOME" => ENV["HOME"], "USER" => ENV["USER"]}

  has_feature :versionable

  if respond_to? :has_command
    has_command :apm, "apm"
  else
    commands :apm => "apm"
  end

  def self.package_list(options={})
    apm_list_cmd = [command(:apm), "list", "--installed", "--bare"]
    begin
      apm_list = execute(apm_list_cmd, :custom_environment => CUSTOM_ENVIRONMENT).lines.
          map { |line| name_version_split(line) }
    rescue Puppet::ExecutionFailure => detail
      raise Puppet::Error, "Could not list packages: #{detail}"
    end
    apm_list.pop until apm_list.last
    Puppet.debug("Returning list of items for #{apm_list}")

    apm_list
  end

  def self.name_version_split(line)
    if line =~ (/^(\S+)@(.+)/)
      name = $1
      version = $2
      {
          :name => name,
          :ensure => version,
          :provider => :apm
      }
    else
      nil
    end
  end

  def self.instances
    package_list.collect { |hash| new(hash) }
  end

  def query
    self.class.instances.each do |package|
      return package.properties if @resource[:name].downcase == package.name.downcase
    end
  end

  def latest
    if /#{resource[:name]}.*-> ([\d\.]+)/ =~ apm('outdated', resource[:name])
      @latest = $1
    else
      @property_hash[:ensure] unless @property_hash[:ensure].is_a? Symbol
    end
  end

  def update
    resource[:ensure] = @latest
    self.install
  end

  def install
    if resource[:ensure].is_a? Symbol
      package = resource[:name]
    else
      package = "#{resource[:name]}@#{resource[:ensure]}"
    end

    if resource[:source]
      apm('install', resource[:source])
    else
      apm('install', package)
    end
  end

  def uninstall
    apm('uninstall', resource[:name])
  end
end
