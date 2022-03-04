(define-module (personal workhorse)
  #:use-module (gnu packages)
  #:use-module (gnu system file-systems)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (rde features)
  #:use-module (rde features base)
  #:use-module (rde features linux)
  #:use-module (rde features system)
  #:use-module (rde features fontutils)
  #:export (workhorse-features))

(define workhorse-filesystems
  (list (file-system ;; System partition
         (device (file-system-label "GUIX"))
         (mount-point "/")
         (type "btrfs"))
        (file-system ;; Boot partition
         (device (file-system-label "BOOT"))
         (mount-point "/boot/efi")
         (type "vfat"))))

(define workhorse-features
  (list
   ;;; Host info
   (feature-host-info #:host-name "workhorse"
                      #:timezone  "Europe/Berlin"
                      #:locale "en_US.UTF-8")

   ;;; Kernel
   (feature-kernel #:kernel linux
                   #:initrd microcode-initrd
                   #:initrd-modules '("vmd")
                   #:firmware (list linux-firmware sof-firmware))

   ;;; File systems
   (feature-file-systems #:file-systems workhorse-filesystems)

   ;;; HiDPI
   (feature-hidpi)

   ;;; Fonts
   (feature-fonts #:font-monospace (font "Iosevka" #:size 13 #:weight 'semi-light))))



