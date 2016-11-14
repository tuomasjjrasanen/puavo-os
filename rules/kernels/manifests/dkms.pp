class kernels::dkms {
  include ::packages

  define install_dkms_module_for_kernel ($kernel_packages, $kernel_version) {
    $titlearray  = split($title, ' ')
    $dkms_module = $titlearray[0]

    case $dkms_module {
      /^bcmwl\//: { $dkms_module_package = 'bcmwl-kernel-source' }

      /^nvidia-current\//: {
        $dkms_module_package = $debianversioncodename ? {
                                 'jessie' => 'nvidia-340xx-kernel-dkms',
                                 default  => 'nvidia-367xx-kernel-dkms',
                               }
      }

      /^nvidia-legacy-304xx\//: {
        $dkms_module_package = 'nvidia-304xx-kernel-dkms'
      }

      /^nvidia-legacy-340xx\//: {
        $dkms_module_package = 'nvidia-340xx-kernel-dkms'
      }

      /^r8168\//: { $dkms_module_package = 'r8168-dkms' }

      default: {
        fail("Unknown package dependency for dkms module ${dkms_module}")
      }
    }

    $ok_filepath = "/var/lib/dkms/${dkms_module}/${kernel_version}.puppetok"

    exec {
      "install dkms module ${dkms_module} for ${kernel_version}":
        command => "/usr/sbin/dkms install ${dkms_module} -k ${kernel_version} && /bin/rm -f /boot/*.old-dkms && /bin/touch ${ok_filepath}",
        creates => $ok_filepath,
        require => [ Package['dkms']
                   , Package[$dkms_module_package]
                   , Package[$kernel_packages] ];
    }

    Package <| title == dkms
            or title == $dkms_module_package
            or title == $kernel_packages |>
  }
}
