# Define: jenkins::job
#
#   This class create a new jenkins job given a name and config xml
#
# Parameters:
#
#   config
#     the content of the jenkins job config file (required)
#
#   source
#     path to a puppet file() resource containing the Jenkins XML job description
#     will override 'config' if set
#
#   template
#     path to a puppet template() resource containing the Jenkins XML job description
#     will override 'config' if set
#
#   jobname = $title
#     the name of the jenkins job
#
#   enabled
#     deprecated parameter (will have no effect if set)
#
#   ensure = 'present'
#     choose 'absent' to ensure the job is removed
#
#   difftool = '/usr/bin/diff -b-q'
#     Provide a command to execute to compare Jenkins job files
#
#   replace = 'true'
#     Wether or not to replace the job if it already exists.
#
define jenkins::job(
  String $config,
  Optional[String] $source                  = undef,
  Optional[Stdlib::Absolutepath] $template  = undef,
  String $jobname                           = $title,
  Any $enabled                              = undef,
  Enum['present', 'absent'] $ensure         = 'present',
  String $difftool                          = '/usr/bin/diff -b -q',
  Boolean $replace                          = true
){

  if $enabled {
    warning("You set \$enabled to ${enabled}, this parameter is now deprecated, nothing will change whatever is its value")
  }

  include ::jenkins::cli

  Class['jenkins::cli']
    -> Jenkins::Job[$title]
      -> Anchor['jenkins::end']

  if ($ensure == 'absent') {
    jenkins::job::absent { $title:
      jobname => $jobname,
    }
  } else {
    if $source {
      $realconfig = file($source)
    }
    elsif $template {
      $realconfig = template($template)
    }
    else {
      $realconfig = $config
    }

    jenkins::job::present { $title:
      config   => $realconfig,
      jobname  => $jobname,
      enabled  => $enabled,
      difftool => $difftool,
      replace  => $replace,
    }
  }

}
