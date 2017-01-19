require File.expand_path(File.join(File.dirname(__FILE__), '..', 'proxysql'))
Puppet::Type.type(:proxy_mysql_replication_hostgroup).provide(:proxysql, :parent => Puppet::Provider::Proxysql) do

  desc 'Manage replication hostgroup for a ProxySQL instance.'
  commands :mysql => 'mysql'

  # Build a property_hash containing all the discovered information about MySQL
  # servers.
  def self.instances
    instances = []
    hostgroups = mysql([defaults_file, '-NBe',
      "SELECT `writer_hostgroup`, `reader_hostgroup`, `comment` FROM `mysql_replication_hostgroups`"].compact).split("\n")

    # To reduce the number of calls to MySQL we collect all the properties in
    # one big swoop.
    hostgroups.each do |line|
      writer_hostgroup, reader_hostgroup, comment = line.split(/\t/)
      name = "#{writer_hostgroup}-#{reader_hostgroup}"

      instances << new(
        :name                   => name,
        :ensure                 => :present,
        :writer_hostgroup       => writer_hostgroup,
        :reader_hostgroup       => reader_hostgroup,
        :comment                => comment
       )
     end
     return instances
   end

   # We iterate over each proxy_mysql_replication_hostgroup entry in the catalog and compare it against
   # the contents of the property_hash generated by self.instances
   def self.prefetch(resources)
     hostgroups = instances
     resources.keys.each do |name|
       if provider = hostgroups.find { |hostgroup| hostgroup.name == name }
         resources[name].provider = provider
       end
     end
   end

   def create
     name             = @resource[:name]
     writer_hostgroup = @resource.value(:writer_hostgroup)
     reader_hostgroup = @resource.value(:reader_hostgroup)
     comment          = @resource.value(:comment) || ''

     query = "INSERT INTO `mysql_replication_hostgroups` (`writer_hostgroup`, `reader_hostgroup`, `comment`)"
     query << " VALUES (#{writer_hostgroup}, #{reader_hostgroup}, '#{comment}')"
     mysql([defaults_file, '-e', query].compact)
     @property_hash[:ensure] = :present

     exists? ? (return true) : (return false)
   end

   def destroy
     writer_hostgroup = @resource.value(:writer_hostgroup)
     reader_hostgroup = @resource.value(:reader_hostgroup)
     query = "DELETE FROM `mysql_replication_hostgroups`"
     query << " WHERE `writer_hostgroup` =  #{writer_hostgroup} AND `reader_hostgroup` = #{reader_hostgroup}"
     mysql([defaults_file, '-e', query].compact)

     @property_hash.clear
     exists? ? (return false) : (return true)
   end

   def exists?
     @property_hash[:ensure] == :present || false
   end

   def flush
     @property_hash.clear
     mysql([defaults_file, '-NBe', 'LOAD MYSQL SERVERS TO RUNTIME'].compact)
     mysql([defaults_file, '-NBe', 'SAVE MYSQL SERVERS TO DISK'].compact)
   end

   # Generates method for all properties of the property_hash
   mk_resource_methods

   def comment=(value)
     writer_hostgroup = @resource.value(:writer_hostgroup)
     reader_hostgroup = @resource.value(:reader_hostgroup)
     query = "UPDATE mysql_replication_hostgroups SET `comment` = '#{value}'"
     query << " WHERE `writer_hostgroup` =  #{writer_hostgroup} AND `reader_hostgroup` = #{reader_hostgroup}"
     mysql([defaults_file, '-e', query].compact)

     @property_hash.clear
     exists? ? (return false) : (return true)
   end


 end
