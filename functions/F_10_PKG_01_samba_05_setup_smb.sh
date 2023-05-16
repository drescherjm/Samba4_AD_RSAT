
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
  sed -e "/^\[global\]/a \ \ template shell = /bin/bash" -i  ${samba_config_file}

  sed -re '/dns\s+forwarder/d' -i ${samba_config_file}
  sed -e "/^\[global\]/a \ \ dns forwarder = ${samba_dns_forwarder}" -i  ${samba_config_file}

  # Remove any include statements 
  sed -re '/include/d' -i ${samba_config_file}
  
  # Start a new global section at the bottom of the file 
  echo "[global]" >> ${samba_config_file}

  # ------------- Samba Log --------------
  mkdir /var/log/samba
  echo "max log size = 10000" >> ${samba_config_file}
  echo "log level = 3 kerberos:5@/var/log/samba/kerberos.log smb:3@/var/log/samba/%I.log smb2:3@/var/log/samba/%I.log" >> ${samba_config_file}
  # ------------- Samba Log --------------

  # ---------- Winbindd Support ----------
  local orig_nocasematch=$(shopt -p nocasematch; true)
  shopt -s nocasematch

  if [[ "${samba_enable_winbind}" = "Yes" ]]; then
     if [[ "$(uname -m)" = "x86_64" ]]; then
       rm -f /lib64/libnss_winbind.so
       ln -s /usr/local/samba/lib/libnss_winbind.so.2 /lib64/
       ln -s /lib64/libnss_winbind.so.2 /lib64/libnss_winbind.so
       ln -s /usr/local/samba/lib/security/pam_winbind.so /usr/lib64/security/pam_winbind.so
       ldconfig
     else
       rm -f /lib/libnss_winbind.so 
       ln -s /usr/local/samba/lib/libnss_winbind.so.2 /lib/
       ln -s /lib/libnss_winbind.so.2 /lib/libnss_winbind.so
       ln -s /usr/local/samba/lib/security/pam_winbind.so /usr/lib/security/pam_winbind.so
       ldconfig
     fi
     # Set the system to use winbindd 
     authselect select winbind with-mkhomedir --force

     systemctl enable --now oddjobd.service

     echo "include=/usr/local/samba/etc/smb-winbind.conf" >> ${samba_config_file}

  fi
  $orig_nocasematch	  

  # ---------- Winbindd Support ----------


  echo "include=/usr/local/samba/etc/smb-kerberos.conf" >> ${samba_config_file}

  # ----------- Shared Folder ------------
  if [[ -n "${samba_share_folder}" ]]; then

    echo "include=/usr/local/samba/etc/shared.conf" >> ${samba_config_file}

    if [[ ! -d "${samba_share_folder}" ]]; then
      mkdir -p ${samba_share_folder}
    fi

    if [[ -d "${samba_share_folder}" ]]; then
      chmod -R 777 ${samba_share_folder}
    fi
    
  fi
  # ----------- Shared Folder ------------

  # Copy the conf files that are included from the templates folder  
  task_copy_using_render_sed

fi
