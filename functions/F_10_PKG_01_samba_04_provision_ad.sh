# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

# --------------Load .bash_profile-------------
# Load .bash_profile to activate samba commands
. ${PLUGINS}/plugin_load_bash_profile.sh
. ${PLUGINS}/plugin_load_databag.sh F_10_PKG_01_samba_00_configure.cfg
# --------------Load .bash_profile-------------

if [[ "${SAMBA_FIRST_DC}" != "0" ]]; then
	samba-tool domain provision --server-role=${samba_server_role} --use-rfc2307 --dns-backend=${samba_dns_backend} --realm=${samba_realm} --domain=${samba_domain} --adminpass=${samba_admin_password}
fi

# A Kerberos configuration suitable for Samba AD has been generated
if [[ -f /usr/local/samba/private/krb5.conf ]]; then
  cat /usr/local/samba/private/krb5.conf > /etc/krb5.conf
fi

# Extract the domain keytab to /etc/krb5.keytab
samba-tool domain exportkeytab /etc/krb5.keytab
