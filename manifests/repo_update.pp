# == helm::repo_update
define helm::repo_update (
  Boolean $debug                     = false,
  Optional[Array] $env               = undef,
  Optional[String] $home             = undef,
  Optional[String] $host             = undef,
  Optional[String] $kube_context     = undef,
  Optional[Array] $path              = undef,
  Optional[String] $tiller_namespace = undef,
  Optional[String] $repository_config= undef,
  Optional[String] $repository_cache = undef,
  Boolean $update                    = true,
){

  include ::helm::params

  if $update {
    $helm_repo_update_flags = helm_repo_update_flags({
      debug             => $debug,
      home              => $home,
      host              => $host,
      kube_context      => $kube_context,
      tiller_namespace  => $tiller_namespace,
      repository_config => $repository_config,
      repository_cache  => $repository_cache,
      update            => $update,
    })
    $exec_update = "helm repo ${helm_repo_update_flags}"
  }

  exec { $title:
    command     => $exec_update,
    environment => $env,
    path        => $path,
    timeout     => 0,
  }
}
