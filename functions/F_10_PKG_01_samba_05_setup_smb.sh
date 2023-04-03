# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable


# --------------Load .bash_profile-------------
# Load .bash_profile to activate samba commands
. ${PLUGINS}/plugin_load_bash_profile.sh
# --------------Load .bash_profile-------------


local samba_config_file="$(smbd -b | grep "CONFIGFILE" | awk '{print $2}')"
if [[ -n "${samba_config_file}" ]]; then
  sed -re '/dns\s+forwarder/d' -i ${samba_config_file}
  sed -e "/^\[global\]/a \ \ dns forwarder = ${samba_dns_forwarder}" -i  ${samba_config_file}

  # ----------- Shared Folder ------------
  if [[ -n "${samba_share_folder}" ]]; then

    sed -re '/include/d' -i ${samba_config_file}
    echo "include=/usr/local/samba/etc/shared.conf" >> ${samba_config_file}
    task_copy_using_render_sed


    if [[ ! -d "${samba_share_folder}" ]]; then
      mkdir -p ${samba_share_folder}
    fi

    if [[ -d "${samba_share_folder}" ]]; then
      chmod -R 777 ${samba_share_folder}
    fi
    
  fi
  # ----------- Shared Folder ------------

  # ---------- Winbindd Support ----------
  local orig_nocasematch=$(shopt -p nocasematch; true)
  shopt -s nocasematch

  if [[ "${samba_enable_winbind}" = "Yes" ]]; then
     if [[ "$(uname -m)" = "x86_64" ]]; then
       ln -s /usr/local/samba/lib/libnss_winbind.so.2 /lib64/
       ln -s /lib64/libnss_winbind.so.2 /lib64/libnss_winbind.so
       ldconfig
     else
       ln -s /usr/local/samba/lib/libnss_winbind.so.2 /lib/
       ln -s /lib/libnss_winbind.so.2 /lib/libnss_winbind.so
       ldconfig
     fi
     # Set the system to use winbindd 
     authselect select winbind with-mkhomedir --force

     systemctl enable --now oddjobd.service

     echo "--------------------------------------------"
     echo " getent passwd                              "
     echo "--------------------------------------------"

     getent passwd

     echo "--------------------------------------------"
     echo " getent group                               "
     echo "--------------------------------------------"

     getent group

  fi
  $orig_nocasematch	  

  # ---------- Winbindd Support ----------

fi
