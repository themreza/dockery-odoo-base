# -----------------
# Multi-stage build
# -----------------
FROM debian:stretch as pyflame-build

USER root
# Build latest pyflame       //-- for live production profiling
RUN apt-get -qq update && apt-get -qq install -y \
       autoconf automake autotools-dev g++ pkg-config python-dev python3-dev libtool make \
       git-core > /dev/null \
    && git clone https://github.com/uber/pyflame.git > /dev/null \
    && cd pyflame \
    && ./autogen.sh > /dev/null \
    && ./configure > /dev/null \
    && make > /dev/null


# -----------------
# Multi-stage build
# -----------------
# Size: ca. 69MB
FROM python:3.7-slim-stretch AS base-build

USER root

# Grab common runtime packages
# Size: ca. 159MB
RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        node-less \
        locales \
        fontconfig \
        lbzip2 \
        libfreetype6 \
        libjpeg62-turbo \
        liblcms2-2 \
        libldap-2.4-2 \
        libsasl2-2 \
        libtiff5 \
        libx11-6 \
        libxext6 \
        libxml2 \
        libxrender1 \
        libxslt1.1 \
        tcl \
        tk \
        zlib1g \
        zlibc \
        # Grab latest git to `pip install` customized python packages & apply patches
        git-core \
        # Apply remote patches
        curl \
        \
        # For wkhtmltox
        libpng16-16 libssl1.1 xfonts-75dpi xfonts-base; \
    \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*;

ENV PSQL_VERSION=11 \
    PSQL_REPO_KEY=B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 \
    WKHTMLTOX_VERSION=0.12.5 \
    WKHTMLTOPDF_CHECKSUM=1140b0ab02aa6e17346af2f14ed0de807376de475ba90e1db3975f112fbd20bb

# Grab runtime packages from non standard repos
# Size: ca. 49MB
RUN set -ex; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends curl $(command -v gpg > /dev/null || echo 'gnupg dirmngr'); \
        # Add postgres apt repo
        echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' >> /etc/apt/sources.list.d/postgresql.list; \
        export GNUPGHOME="$(mktemp -d)"; \
        gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${PSQL_REPO_KEY}"; \
        gpg --armor --export "${PSQL_REPO_KEY}" | apt-key add -; \
        gpgconf --kill all; \
        rm -rf "$GNUPGHOME"; \
        # Grab wkhtmltopdf
        curl --silent --show-error --location --output wkhtmltox.deb https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/${WKHTMLTOX_VERSION}/wkhtmltox_${WKHTMLTOX_VERSION}-1.stretch_amd64.deb; \
        echo "${WKHTMLTOPDF_CHECKSUM}  wkhtmltox.deb" | sha256sum -c -; \
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        postgresql-client-${PSQL_VERSION}; \
        \
        dpkg -i ./wkhtmltox.deb; \
        rm wkhtmltox.deb; \
        rm /usr/local/bin/wkhtmltoimage; \
        rm /usr/local/lib/libwkhtmltox.so*; \
        wkhtmltopdf --version; \
    \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*;

# Build-time env
ENV ODOO_BCKP_DIR="/var/lib/odoo-backups" \
    ODOO_PRST_DIR="/var/lib/odoo-persist" \
    APP_UID="9001" \
    APP_GID="9001" \
    ODOO_VERSION=master


# Grab & build required python packages
# Size: ca. 126MB
COPY requirements.txt /requirements.txt
RUN set -ex; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential \
        bzip2 \
        libgeoip-dev \
        xz-utils \
        libevent-dev \
        libssl-dev \
        # lxml
        libxml2-dev \
        libxslt1-dev\
        # Pillow
        libjpeg-dev \
        libfreetype6-dev \
        liblcms2-dev \
        libtiff5-dev \
        tk-dev \
        tcl-dev \
        # psutil
        linux-headers-amd64 \
        # psycopg2
        libpq-dev \
        # python-ldap
        libldap2-dev \
        libsasl2-dev; \
    \
    pip --quiet --quiet install --no-cache-dir --requirement /requirements.txt; \
    pip --quiet --quiet install --no-cache-dir phonenumbers; \
    find /usr/local -depth \
        \( \
            \( -type d -a \( -name test -o -name tests \) \) \
            -o \
            \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
        \) -exec rm -rf '{}' +; \
    \
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*;

# Grab pyflame binary        //-- for live production profiling
# Size: ca. 1.5MB
COPY --from=pyflame-build /pyflame/src/pyflame /usr/local/bin/
RUN chmod +x /usr/local/bin/pyflame


# Grab latest geoip DB       //-- to enable IP based geo-referncing
# Size: ca. 73MB
RUN set -ex; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends wget; \
    \
    wget --quiet http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz -O /tmp/GeoLite2-City.tar.gz; \
    mkdir -p /usr/share/GeoIP; \
    tar -xf /tmp/GeoLite2-City.tar.gz -C /tmp/; \
    find /tmp/GeoLite2-City_* | grep "GeoLite2-City.mmdb" | xargs -I{} mv {} /usr/share/GeoIP/GeoLite2-City.mmdb; \
    rm -rf /tmp/*; \
    pip --quiet --quiet install --no-cache-dir geoip2; \
    \
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*;

# Grab latest json logger    //-- for easier parsing (Patch 0001)
RUN pip --quiet --quiet install --no-cache-dir python-json-logger; \
	find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' +;


# Copy from build env
COPY . /
RUN /bin/bash -c 'shopt -s dotglob \
 && chmod +x /patches \
 && chmod +x /entrypoint.sh \
 && chmod +x /entrypoint.d/* \
 && chmod +x /entrypoint.db.d/* \
 && shopt -u dotglob'

# Create app user & folders
RUN addgroup --system --gid $APP_UID odoo; \
    adduser --system --uid $APP_GID --ingroup odoo --home /opt/odoo --disabled-login --shell /sbin/nologin odoo; \
    mkdir -p "${ODOO_PRST_DIR}" "${ODOO_BCKP_DIR}"; \
    chown -R odoo:odoo "${ODOO_PRST_DIR}" "${ODOO_BCKP_DIR}"; \
    rm /var/log/faillog var/log/lastlog;

# Fix locale                 //-- for some tests that depend on locale (babel python-lib)
# Size: ca. 3.6MB
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

ENTRYPOINT ["/entrypoint.sh"]
VOLUME ["${ODOO_PRST_DIR}", "${ODOO_BCKP_DIR}"]

USER odoo

# Grab newer werkzeug        //-- for right IP in logs https://git.io/fNu6v
# Size: ca. 1.9MB
RUN pip --quiet --quiet install --no-cache-dir --user Werkzeug==0.14.1; \
    find /usr/local -depth \
        \( \
            \( -type d -a \( -name test -o -name tests \) \) \
            -o \
            \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
        \) -exec rm -rf '{}' +;
