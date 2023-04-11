# Ref. https://wiki.samba.org/index.php/Package_Dependencies_Required_to_Build_Samba#Verified_Package_Dependencies

dnf install -y dnf-plugins-core epel-release

# ----------------------------------------------------------------------------------------
# Enable repo Devel
# ----------------------------------------------------------------------------------------
# check repo
local verify_repo="$(dnf repolist --enabled 2>&1  | grep 'Devel')"
      verify_repo="$([[ -z "${verify_repo}" ]] && echo "FAILED")"

if [[ "${verify_repo}" = "FAILED" ]]; then
  dnf config-manager --set-enabled devel
fi

verify_repo="$(dnf repolist --enabled 2>&1  | grep 'CRB')"
      verify_repo="$([[ -z "${verify_repo}" ]] && echo "FAILED")"

if [[ "${verify_repo}" = "FAILED" ]]; then
  dnf config-manager --set-enabled crb
fi

dnf upgrade -y


dnf install -y \
    nano \
    bash-completion \
    adcli \
    krb5-workstation \
    e2fsprogs \
    screen \
    realmd \
    wget \
    net-tools \
    oddjob-mkhomedir \
    sssd \
    sssd-tools

dnf install -y \
    "@Development Tools" \
    acl \
    attr \
    autoconf \
    avahi-devel \
    bind-utils \
    binutils \
    bison \
    chrpath \
    cups-devel \
    curl \
    dbus-devel \
    docbook-dtds \
    docbook-style-xsl \
    flex \
    gawk \
    gcc \
    gdb \
    git \
    glib2-devel \
    glibc-common \
    glibc-langpack-en \
    glusterfs-api-devel \
    glusterfs-devel \
    gnutls-devel \
    gpgme-devel \
    gzip \
    hostname \
    htop \
    jansson-devel \
    keyutils-libs-devel \
    krb5-devel \
    krb5-server \
    libacl-devel \
    libarchive-devel \
    libattr-devel \
    libblkid-devel \
    libbsd-devel \
    libcap-devel \
    libcephfs-devel \
    libicu-devel \
    libnsl2-devel \
    libpcap-devel \
    libtasn1-devel \
    libtasn1-tools \
    libtirpc-devel \
    libunwind-devel \
    libuuid-devel \
    libxslt \
    lmdb \
    lmdb-devel \
    make \
    mingw64-gcc \
    ncurses-devel \
    openldap-devel \
    pam-devel \
    patch \
    perl \
    perl-Archive-Tar \
    perl-ExtUtils-MakeMaker \
    perl-Parse-Yapp \
    perl-Test-Simple \
    perl-generators \
    perl-interpreter \
    perl-JSON \
    pkgconfig \
    popt-devel \
    procps-ng \
    psmisc \
    python3 \
    python3-devel \
    python3-dns \
    python3-gpg \
    python3-libsemanage \
    python3-markdown \
    python3-policycoreutils \
    python3-requests \
    python3-cryptography \
    readline-devel \
    redhat-lsb \
    rng-tools \
    rpcgen \
    rpcsvc-proto-devel \
    rsync \
    sed \
    sudo \
    systemd-devel \
    tar \
    tree \
    which \
    xfsprogs-devel \
    yum-utils \
    zlib-devel

