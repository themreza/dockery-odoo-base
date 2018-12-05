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
FROM debian:stretch AS base-build

USER root


# Library versions
ENV ODOO_VERSION         12.0
ENV PSQL_VERSION         10
ENV WKHTMLTOX_VERSION    0.12.5
ENV WKHTMLTOPDF_CHECKSUM 1140b0ab02aa6e17346af2f14ed0de807376de475ba90e1db3975f112fbd20bb
ENV NODE_VERSION         6

# Build-time env
ENV ODOO_BASEPATH        "/opt/odoo"
ENV ODOO_RC              "${ODOO_BASEPATH}/cfg.d"
ENV ODOO_MIG             "${ODOO_BASEPATH}/migration.yaml"
ENV ODOO_CMD             "${ODOO_BASEPATH}/odoo-bin"
ENV ODOO_FRM             "${ODOO_BASEPATH}/odoo"
ENV ODOO_ADDONS_BASEPATH "${ODOO_BASEPATH}/addons"
ENV ODOO_BCKP_DIR        "/var/lib/odoo-backups"
ENV ODOO_PRST_DIR        "/var/lib/odoo-persist"
ENV APP_UID              "9001"
ENV APP_GID              "9001"

# Grab build deps
RUN apt-get -qq update && apt-get -qq install -y --no-install-recommends \
    build-essential \
    bzip2 \
    curl \
    libgeoip-dev \
    python3-dev \
    wget \
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
    # python-ldap
    libldap2-dev \
    libsasl2-dev \
    > /dev/null

# Grab run deps
RUN apt-get -qq update && apt-get -qq install -y --no-install-recommends \
    python3 \
    apt-transport-https \
    ca-certificates \
    gnupg2 \
    locales \
    fontconfig \
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
    > /dev/null


# Grab latest pip
RUN curl --silent --show-error --location https://bootstrap.pypa.io/get-pip.py | python3 /dev/stdin --no-cache-dir

# Grab latest git            //-- to `pip install` customized python packages & apply patches
RUN apt-get -qq update && apt-get -qq install -y --no-install-recommends git-core > /dev/null

# Grab postgres
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' >> /etc/apt/sources.list.d/postgresql.list
RUN curl --silent --show-error --location https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get -qq update && apt-get -qq install -y --no-install-recommends postgresql-client-${PSQL_VERSION} > /dev/null

# Grab pip dependencies
COPY requirements.txt /requirements.txt
RUN pip --quiet --quiet install --no-cache-dir --requirement /requirements.txt
RUN pip --quiet --quiet install --no-cache-dir phonenumbers

# Grab wkhtmltopdf
RUN curl --silent --show-error --location --output wkhtmltox.deb https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/${WKHTMLTOX_VERSION}/wkhtmltox_${WKHTMLTOX_VERSION}-1.stretch_amd64.deb
RUN echo "${WKHTMLTOPDF_CHECKSUM}  wkhtmltox.deb" | sha256sum -c -
RUN apt-get -qq update && apt-get -qq install -yqq --no-install-recommends libpng16-16 libssl1.1 xfonts-75dpi xfonts-base > /dev/null
RUN dpkg -i ./wkhtmltox.deb && rm wkhtmltox.deb && wkhtmltopdf --version

# Grab web stack
RUN echo "deb https://deb.nodesource.com/node_${NODE_VERSION}.x stretch main" > /etc/apt/sources.list.d/nodesource.list
RUN echo "deb-src https://deb.nodesource.com/node_${NODE_VERSION}.x stretch main" >> /etc/apt/sources.list.d/nodesource.list
RUN curl --silent --show-error --location https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
RUN apt-get -qq update && apt-get -qq install -y --no-install-recommends \
    gem \
    nodejs \
    ruby-compass \
    > /dev/null \
    && ln -s /usr/bin/nodejs /usr/local/bin/node \
    && npm install --quiet --global less \
    && rm -Rf ~/.gem /var/lib/gems/*/cache/ \
    && rm -Rf ~/.npm /tmp/*

# Grab pyflame binary        //-- for live production profiling
COPY --from=pyflame-build /pyflame/src/pyflame /usr/local/bin/
RUN chmod +x /usr/local/bin/pyflame


# Grab latest geoip DB       //-- to enable IP based geo-referncing
RUN wget --quiet http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz \
    && gunzip GeoLiteCity.dat.gz \
    && mkdir -p /usr/share/GeoIP \
    && mv GeoLiteCity.dat /usr/share/GeoIP/ \
    && pip --quiet --quiet install GeoIP

# Grab latest json logger    //-- for easier parsing (Patch 0001)
RUN pip --quiet --quiet install python-json-logger

# Create app user
RUN addgroup --system --gid $APP_UID odoo
RUN adduser --system --uid $APP_GID --ingroup odoo --home /opt/odoo --disabled-login --shell /sbin/nologin odoo

# Copy from build env
COPY entrypoint* /
COPY entrypoint.d /entrypoint.d
COPY entrypoint.db.d /entrypoint.db.d
COPY patches /patches

# Own folders                //-- where pure bind mounting during dev in docker-compose doesn't yield correct file permissions
RUN mkdir -p "${ODOO_PRST_DIR}" "${ODOO_BCKP_DIR}"
RUN chown -R odoo:odoo "${ODOO_PRST_DIR}" "${ODOO_BCKP_DIR}"

ENTRYPOINT ["/entrypoint.sh"]
VOLUME ["${ODOO_PRST_DIR}", "${ODOO_BCKP_DIR}"]

# Fix locale                 //-- for some tests that depend on locale (babel python-lib)
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN /bin/bash -c 'shopt -s dotglob \
 && chmod +x /patches \
 && chmod +x /entrypoint.sh \
 && chmod +x /usr/local/bin/* \
 && chmod +x /entrypoint.d/* \
 && chmod +x /entrypoint.db.d/* \
 && shopt -u dotglob'

USER odoo

# Grab newer werkzeug        //-- for right IP in logs https://git.io/fNu6v
RUN pip --quiet --quiet install --user Werkzeug==0.14.1
