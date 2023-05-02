# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

# --------------Load .bash_profile-------------
# Load .bash_profile to activate samba commands
. ${PLUGINS}/plugin_load_bash_profile.sh
. ${PLUGINS}/plugin_load_databag.sh F_10_PKG_01_samba_00_configure.cfg
# --------------Load .bash_profile-------------

function  setup_smb_conf {
  cat << EOF > /usr/local/samba/etc/smb.conf.new
[global]
   SERVER ROLE = ACTIVE DIRECTORY DOMAIN CONTROLLER
   netbios name = ${this_hostname_short}
   realm = ${samba_realm}
   workgroup = ${samba_domain}

   idmap_ldb:use rfc2307 = yes
   apply group policies = yes

[sysvol]
      path = /usr/local/samba/var/locks/sysvol
      read only = No

[netlogon]
      path = /usr/local/samba/var/locks/sysvol/${samba_realm,,}/scripts
      read only = No  
EOF

# Prepend the /usr/local/samba/etc/smb.conf.new to the existing /usr/local/samba/etc/smb.conf
cp -n /usr/local/samba/smb.conf /usr/local/samba/smb.conf.bak
mv /usr/local/samba/etc/smb.conf.new /usr/local/samba/etc/smb.conf
cat /usr/local/samba/smb.conf.bak >> /usr/local/samba/etc/smb.conf

}



if [[ "${samba_first_dc}" != "0" ]]; then
	samba-tool domain provision --server-role=${samba_server_role} --use-rfc2307 --dns-backend=${samba_dns_backend} --realm=${samba_realm} --domain=${samba_domain} --adminpass=${samba_admin_password}
else 
	setup_smb_conf

	echo "samba-tool domain join ${samba_realm} DC -UAdministrator -W${samba_domain} --password=${samba_admin_password} --server=${samba_existing_dc} --dns-backend=${samba_dns_backend} --verbose"
	samba-tool domain join ${samba_realm} DC -UAdministrator -W${samba_domain} --password=${samba_admin_password} --server=${samba_existing_dc} --dns-backend=${samba_dns_backend} --verbose
fi

# A Kerberos configuration suitable for Samba AD has been generated
if [[ -f /usr/local/samba/private/krb5.conf ]]; then
  cat /usr/local/samba/private/krb5.conf > /etc/krb5.conf
fi

# Extract the domain keytab to /etc/krb5.keytab
samba-tool domain exportkeytab /etc/krb5.keytab
