class repomanager::params {
  $obsdpkgconfdefaults = {
    fullwidth   => 'yes',
    loglevel    => '1',
    installpath => "http://ftp.openbsd.org/pub/OpenBSD/${kernelmajversion}/packages/${hardwaremodel}/",
    nochecksum  => 'no',
    ntogo       => 'yes',
  }
}
