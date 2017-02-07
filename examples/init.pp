# lint:ignore:80chars
apt::source{ 'debs_jessie_mysql_dev':
  comment  => 'MySQL-dev repo',
  location => 'http://debs.ugent.be/debian',
  repos    => 'mysql-dev',
}->
class { '::proxysql':
  listen_port    => 3306,
  admin_password => 'SuperSecretPassword',
}

proxy_mysql_server { '192.168.33.31:3306-31':
  hostname     => '192.168.33.31',
  port         => 3306,
  hostgroup_id => 31,
}
proxy_mysql_server { '192.168.33.32:3306-31':
  hostname     => '192.168.33.32',
  port         => 3306,
  hostgroup_id => 31,
}
proxy_mysql_server { '192.168.33.33:3306-31':
  hostname     => '192.168.33.33',
  port         => 3306,
  hostgroup_id => 31,
}
proxy_mysql_server { '192.168.33.34:3306-31':
  hostname     => '192.168.33.34',
  port         => 3306,
  hostgroup_id => 31,
}
proxy_mysql_server { '192.168.33.35:3306-31':
  hostname     => '192.168.33.35',
  port         => 3306,
  hostgroup_id => 31,
}

proxy_mysql_replication_hostgroup { '30-31':
  writer_hostgroup => 30,
  reader_hostgroup => 31,
  comment          => 'Replication Group 1',
}
proxy_mysql_replication_hostgroup { '20-21':
  writer_hostgroup => 20,
  reader_hostgroup => 21,
  comment          => 'Replication Group 2',
}

proxy_mysql_user { 'tester':
  password          => 'testerpwd',
  default_hostgroup => 30,
}

proxy_mysql_query_rule { 'mysql_query_rule-1':
  rule_id               => 1,
  match_pattern         => '^SELECT',
  apply                 => 1,
  active                => 1,
  destination_hostgroup => 31,
}
# lint:endignore
