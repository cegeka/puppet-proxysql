# @summary This class is called from proxysql to update config if it changed.
#
# @api private
class proxysql::reload_config {
  $subscribe = $proxysql::split_config ? {
    true  => [File['proxysql-config-file'], File['proxysql-proxy-config-file']],
    false => File['proxysql-config-file'],
  }

  $mycnf_file_name = $proxysql::mycnf_file_name
  exec { 'reload-config':
    # Prepended the executed mysql command with a sleep command to avoid a race condition which was reached consistently during testing
    # when updating both user and server configuration. This could leave ProxySQL with reconfigured server but outdated user configuration
    # as the mysql command could not be executed succesfully briefly after updating the server configuration. Adding a brief delay to
    # this exec effectivly seems to resolves this, side-stepping the need for 2 puppet runs to apply all configuration changes.
    # It's not pretty, but it seems to effectivly and consistencly avoid the issue.
    command     => "/usr/bin/sleep 1 && /usr/bin/mysql --defaults-extra-file=${mycnf_file_name} --execute=\"
          LOAD ADMIN VARIABLES FROM CONFIG; \
          LOAD ADMIN VARIABLES TO RUNTIME; \
          SAVE ADMIN VARIABLES TO DISK; \
          LOAD MYSQL VARIABLES FROM CONFIG; \
          LOAD MYSQL VARIABLES TO RUNTIME; \
          SAVE MYSQL VARIABLES TO DISK; \"
        ",
    subscribe   => $subscribe,
    require     => [Service[$proxysql::service_name], File['root-mycnf-file']],
    refreshonly => true,
  }
}
