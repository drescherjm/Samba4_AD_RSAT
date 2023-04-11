# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

# --------------Load .bash_profile-------------
# Load .bash_profile to activate samba commands
. ${PLUGINS}/plugin_load_bash_profile.sh
# --------------Load .bash_profile-------------

dnf install -y jq

#echo ${group_data}

for row in $(echo "${group_data}" | jq -r '.[] | @base64'); do
    _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
    }

   # Get the Group Name from the JSON string in the databag
   local group=$(_jq '.GroupName')

   # Generate a GID by looking for non-used GIDs in the range of 2000 to 10000
   local gid_generated=$(getent group | awk -F: '{uid[$3]=1}END{for(x=2000;x<=10000;x++)if(!uid[x]){print x;exit}}')
   samba-tool group create "${group}" --nis-domain=${samba_domain} --gid-number=${gid_generated}

done


#echo ${user_data}

for row in $(echo "${user_data}" | jq -r '.[] | @base64'); do
    _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
    }
   #echo $(_jq '.UserName'), $(_jq '.Password'), $(_jq '.Groups')
   local  username=$(_jq '.UserName')
   local  password=$(_jq '.Password')
   local  groups=$(_jq '.Groups')
   local  uid_generated=$(getent passwd | awk -F: '{uid[$3]=1}END{for(x=2000;x<=10000;x++)if(!uid[x]){print x;exit}}')

   samba-tool user create "${username}" ${password} --nis-domain=${samba_domain} --uid-number=${uid_generated} --gid-number=100 --login-shell=/bin/bash --unix-home=/home/${username}

   for group in $(echo "${groups}" | jq -r '.[]' ); do
     samba-tool group addmembers "${group}" "${username}"
   done 

done
