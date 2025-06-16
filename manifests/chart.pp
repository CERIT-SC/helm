# == helm::chart 
define helm::chart (
  String $ensure                      = present,
  Optional[String] $ca_file           = undef,
  Optional[String] $cert_file         = undef,
  Optional[String] $chart             = undef,
  Boolean $debug                      = false,
  Boolean $devel                      = false,
  Boolean $dry_run                    = false,
  Optional[Array] $env                = undef,
  Optional[String] $key_file          = undef,
  Optional[String] $key_ring          = undef,
  Optional[String] $home              = undef,
  Optional[String] $host              = undef,
  Optional[String] $kube_context      = undef,
  Optional[String] $name_template     = undef,
  Optional[String] $namespace         = undef,
  Boolean $no_hooks                   = false,
  Optional[Array] $path               = undef,
  Boolean $purge                      = true,
  Boolean $replace                    = false,
  Optional[String] $repo              = undef,
  Optional[String] $release_name      = undef,
  Optional[String] $repository_config= undef,
  Optional[String] $repository_cache = undef,
  Optional[Array] $set                = [],
  Optional[Integer] $timeout          = undef,
  Boolean $tls                        = false,
  Optional[String] $tls_ca_cert       = undef,
  Optional[String] $tls_cert          = undef,
  Optional[String] $tls_key           = undef,
  Boolean $tls_verify                 = false,
  Optional[Array] $values             = [],
  Boolean $verify                     = false,
  Optional[String] $version           = undef,
  Boolean $wait                       = false,
  Boolean $upgrade                    = false,
){

  include ::helm::params

  if ($release_name == undef) {
    fail(translate("\nYou must specify a name for the service with the release_name attribute \neg: release_name => 'mysql'"))
  }

  if $ensure == present {
    $helm_install_upgrade_flags = helm_install_upgrade_flags({
      ensure            => $ensure,
      ca_file           => $ca_file,
      cert_file         => $cert_file,
      chart             => $chart,
      debug             => $debug,
      devel             => $devel,
      dry_run           => $dry_run,
      key_file          => $key_file,
      key_ring          => $key_ring,
      home              => $home,
      host              => $host,
      kube_context      => $kube_context,
      name_template     => $name_template,
      namespace         => $namespace,
      no_hooks          => $no_hooks,
      replace           => $replace,
      repo              => $repo,
      repository_config => $repository_config,
      repository_cache  => $repository_cache,
      release_name      => $release_name,
      set               => $set,
      timeout           => $timeout,
      tls               => $tls,
      tls_ca_cert       => $tls_ca_cert,
      tls_cert          => $tls_cert,
      tls_key           => $tls_key,
      tls_verify        => $tls_verify,
      values            => $values,
      verify            => $verify,
      version           => $version,
      wait              => $wait,
      })
    $exec = "helm install ${name}"
    $exec_chart = "helm install ${helm_install_upgrade_flags}"
    $helm_ls_flags = helm_ls_flags({
      ls => true,
      home => $home,
      host => $host,
      kube_context => $kube_context,
      namespace => $namespace,
      short => false,
      tls => $tls,
      tls_ca_cert => $tls_ca_cert,
      tls_cert => $tls_cert,
      tls_key => $tls_key,
      tls_verify => $tls_verify,
    })
    $unless_chart = "helm ${helm_ls_flags} | grep -q '${release_name}'"
    exec { $exec:
      command     => $exec_chart,
      environment => $env,
      path        => $path,
      timeout     => 0,
      tries       => 10,
      try_sleep   => 10,
      unless      => $unless_chart,
    }

    if $upgrade {
      $onlyif_upgrade = "/bin/bash -c 'X=`helm diff upgrade ${helm_install_upgrade_flags} | wc -l` ; [[ \$X -gt 0 ]]'"

      exec { "helm upgrade ${name} diff":
        command     => "helm upgrade ${helm_install_upgrade_flags}",
        environment => $env,
        path        => $path,
        timeout     => 0,
        tries       => 10,
        try_sleep   => 10,
        onlyif      => $onlyif_upgrade,
      }
    }
    
    if $version != undef {
      $upgrade_name = "helm upgrade ${name}"
      $upgrade_chart = "helm upgrade ${helm_install_upgrade_flags}"
      $onlyif_chart = "/bin/bash -c 'X=`helm ${helm_ls_flags}`; [[ \$X == *${release_name}* ]] && [[ \$X != *${release_name}-v${version}* ]] && [[ \$X != *${release_name}-${version}* ]]'"
      exec { $upgrade_name:
        command     => $upgrade_chart,
        environment => $env,
        path        => $path,
        timeout     => 0,
        tries       => 10,
        try_sleep   => 10,
        onlyif      => $onlyif_chart,
      }
    }
  }

  if $ensure == absent {
    $helm_delete_flags = helm_delete_flags({
      ensure => $ensure,
      debug => $debug,
      dry_run => $dry_run,
      home => $home,
      host => $host,
      kube_context => $kube_context,
      name_template => $name_template,
      namespace => $namespace,
      no_hooks => $no_hooks,
      purge => $purge,
      release_name => $release_name,
      timeout => $timeout,
      tls => $tls,
      tls_ca_cert => $tls_ca_cert,
      tls_cert => $tls_cert,
      tls_key => $tls_key,
      tls_verify => $tls_verify,
      })
    $exec = "helm delete ${name}"
    $exec_chart = "helm ${helm_delete_flags}"
    $helm_ls_flags = helm_ls_flags({
      ls => true,
      home => $home,
      host => $host,
      kube_context => $kube_context,
      short => true,
      tls => $tls,
      tls_ca_cert => $tls_ca_cert,
      tls_cert => $tls_cert,
      tls_key => $tls_key,
      tls_verify => $tls_verify,
    })
    $unless_chart = "helm ${helm_ls_flags} | awk '{if(\$1 == \"${release_name}\") exit 1}'"

    exec { $exec:
      command     => $exec_chart,
      environment => $env,
      path        => $path,
      timeout     => 0,
      tries       => 10,
      try_sleep   => 10,
      unless      => $unless_chart,
    }
  }
}
