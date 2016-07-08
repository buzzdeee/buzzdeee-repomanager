# Configures the S3 APT repo

class repomanager::apt_s3_driver (
  $s3_driver_url = undef,
) {

  if $s3_driver_url {

    ::Apt::Source <| |> {
      require +> Package['apt-boto-s3']
    }

    exec{ 'download_apt_boto_s3':
      command => "/usr/bin/wget -q ${s3_driver_url} -O /tmp/apt-boto-s3.deb",
      creates => '/tmp/apt-boto-s3.deb',
    }

    package { 'boto3':
      ensure   => 'present',
      provider => 'pip',
    }

    package { 'apt-boto-s3':
      ensure   => 'latest',
      provider => 'dpkg',
      source   => '/tmp/apt-boto-s3.deb',
      require  => [Exec['download_apt_boto_s3'], Package['boto3']],
    }
  }
}
