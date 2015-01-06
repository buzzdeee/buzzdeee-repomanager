class repomanager::obsdpkgconf (
  $config,
  $configdefaults
) {
  if $config {
    $pkgconfig = deep_merge($configdefaults, $config)
  } else {
    $pkgconfig = $configdefaults
  }

  file { '/etc/pkg.conf':
    owner   => 'root',
    group   => '0',
    mode    => '0644',
    content => template('repomanager/pkg.conf.erb')
  }
}
