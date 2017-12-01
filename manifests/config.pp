# This class should be considered private
#
class jenkins::config {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  ensure_resource('jenkins::plugin', $::jenkins::default_plugins)

  $config_hash = merge(
    $::jenkins::params::config_hash_defaults,
    $::jenkins::config_hash
  )
  create_resources('jenkins::sysconfig', $config_hash)

  # Lets manage the bootstrap directory
  if $::jenkins::manage_bootstrapping {

    # Some more validation, as empty var leads to purge /init.groovy.d
    if empty($::jenkins::jenkins_home) {
      fail("ERROR: Need a jenkins home dir if \$::jenkins::manage_bootstrapping is enabled")
    }

    # Do we and only we manage the dir ?
    if $::jenkins::purge_bootstrapping {
      $_purge_bootstrapping_dir = true
      $_recurse_bootstrapping_dir = true
    } else {
      $_purge_bootstrapping_dir = false
      $_recurse_bootstrapping_dir = false
    }

    file { "${::jenkins::jenkins_home}/init.groovy.d":
      ensure  => directory,
      owner   => $::jenkins::user,
      group   => $::jenkins::group,
      mode    => '0750',
      tag     => 'jenkins_groovy_init_script',
      purge   => $_purge_bootstrapping_dir,
      recurse => $_recurse_bootstrapping_dir,
    }

    # Restart jenkins if content changed
    File <| tag == 'jenkins_groovy_init_script' |> ~> Service <| title == 'jenkins' |>

  }

  $_jenkins_sshd_port = $::jenkins::jenkins_sshd_port

  if $::jenkins::manage_bootstrapping and $::jenkins::jenkins_sshd_port {
    $_sshd_groovy_ensure = present
  } else {
    $_sshd_groovy_ensure = absent
  }

  file { "${::jenkins::jenkins_home}/init.groovy.d/puppet.sshd.groovy":
    ensure    => $_sshd_groovy_ensure,
    owner     => $::jenkins::user,
    group     => $::jenkins::group,
    mode      => '0644',
    tag       => 'jenkins_groovy_init_script',
    show_diff => true,
    content   => template('jenkins/home/jenkins/init.groovy.d/puppet.sshd.groovy.erb'),
  }
}
