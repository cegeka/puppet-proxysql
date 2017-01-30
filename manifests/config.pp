# == Class proxysql::config
#
# This class is called from proxysql for service config.
#
class proxysql::config {

  $config_settings = $::proxysql::config_settings
  if $proxysql::manage_config_file  {
    file { 'proxysql-config-file':
      ensure                  => file,
      path                    => $proxysql::config_file,
      content                 => template('proxysql/proxysql.cnf.erb'),
      mode                    => '0640',
      owner                   => 'root',
      group                   => 'root',
      selinux_ignore_defaults => true,
    }
  }

  if $proxysql::manage_mycnf_file {
    file { 'root-mycnf-file':
      ensure  => file,
      path    => $proxysql::mycnf_file_name,
      content => template('proxysql/my.cnf.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0400',
    }
  }
}
