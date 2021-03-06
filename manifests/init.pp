# == Class: repomanager
#
# Full description of class repomanager here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'repomanager':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Sebastian Reitenbach <sebastia@l00-bugdead-prods.de>
#
# === Copyright
#
# Copyright 2015 Sebastian Reitenbach, unless otherwise noted.
#
class repomanager (
  $virtualzypprepos   = undef,
  $virtualzypprepodefaults = undef,
  $zypprepos = undef,
  $obsdpkgconf = undef,
) inherits repomanager::params {
  case $::osfamily {
    'Suse': {
      case $::operatingsystem {
        'SLES': {
          file { '/etc/cron.d/novell.com-suse_register':
            ensure => 'absent',
          }
        }
      }
      if $virtualzypprepos[$::operatingsystem] and $virtualzypprepos[$::operatingsystem][$::operatingsystemrelease] {
        if $virtualzypprepodefaults {
          create_resources('@zypprepo', $virtualzypprepos[$::operatingsystem][$::operatingsystemrelease], $virtualzypprepodefaults)
        } else {
          create_resources('@zypprepo', $virtualzypprepos[$::operatingsystem][$::operatingsystemrelease])
        }
      }
      if $zypprepos[$::operatingsystem] and $zypprepos[$::operatingsystem][$::operatingsystemrelease] {
        $zypprepos[$::operatingsystem][$::operatingsystemrelease].each |$repo| {
          Zypprepo[$repo] -> Package <| |>
          realize(Zypprepo[$repo])
        }
      }
    }
    'OpenBSD': {
      Class['repomanager::obsdpkgconf'] -> Package <| |>
      class { 'repomanager::obsdpkgconf':
        config         => $obsdpkgconf,
        configdefaults => $params::obsdpkgconfdefaults,
      }
    }
    'Debian': {
      case $::operatingsystem {
        'Ubuntu': {
          include apt

          $apt_settings = hiera_hash('apt::apt_settings', {})
          create_resources('apt::setting', $apt_settings)

          $apt_sources = hiera_hash('apt::apt_sources', {})
          create_resources('apt::source', $apt_sources)

          $apt_pins = hiera_hash('apt::apt_pins', {})
          create_resources('apt::pin', $apt_pins)

          $ppa_repos = hiera_hash('repomanager::ppa_repos', {})
          create_resources('apt::ppa', $ppa_repos, {require => Class['apt']})

          # Exec['apt_update'] -> Package <| provider == 'apt' |>
          # does't work, Implicit properties aren’t searchable by collectors :(
          Class['apt::update'] ->
          Package <| provider != 'pip' and provider != 'dpkg' and provider != 'gem' |>

          include 'repomanager::apt_s3_driver'
        }
      }
    }
    'default': {
      notify { "$::osfamily is not supported by repomanager": }
    }
  }
}
