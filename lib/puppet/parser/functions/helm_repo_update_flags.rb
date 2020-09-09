require 'shellwords'
#
# helm_repo_update_flags.rb
#
module Puppet::Parser::Functions
  # Transforms a hash into a string of helm repo update flags
  newfunction(:helm_repo_update_flags, :type => :rvalue) do |args|
    opts = args[0] || {}
    flags = []
    flags << '--debug' if opts['debug']
    flags << "--home '#{opts['home']}'" if opts['home'] && opts['home'].to_s != 'undef'
    flags << "--host '#{opts['host']}'" if opts['host'] && opts['host'].to_s != 'undef'
    flags << "--kube-context '#{opts['kube_context']}'" if opts['kube_context'] && opts['kube_context'].to_s != 'undef'
    flags << "--tiller-namespace '#{opts['tiller_namespace']}'" if opts['tiller_namespace'] && opts['tiller_namespace'].to_s != 'undef'
    flags << "--repository-config '#{opts['repository_config']}'" if opts['repository_config'] && opts['repository_config'].to_s != 'undef'
    flags << "--repository-cache '#{opts['repository_cache']}'" if opts['repository_cache'] && opts['repository_cache'].to_s != 'undef'
    flags << 'update' if opts['update']
    flags.flatten.join(' ')
  end
end
