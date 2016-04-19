class repomanager::obsdpkgconf (
  $config,
  $configdefaults,
) {
  if $config {
    $pkgconfig = deep_merge($configdefaults, $config)
  } else {
    $pkgconfig = $configdefaults
  }

  $majversion = $::os[release][major]
  $minversion = $::os[release][minor]
  $version = "${majversion}${minversion}"
  exec { 'fetch_mtier_pubkey':
    command => "/usr/bin/ftp -o /etc/signify/mtier-${version}-pkg.pub https://stable.mtier.org/mtier-${version}-pkg.pub",
    creates => "/etc/signify/mtier-${version}-pkg.pub"
  }

  file { '/etc/pkg.conf':
    owner   => 'root',
    group   => '0',
    mode    => '0644',
    content => template('repomanager/pkg.conf.erb')
  }
}
