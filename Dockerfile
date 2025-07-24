FROM judge0/compilers:1.4.0 AS production

ENV JUDGE0_HOMEPAGE "https://judge0.com"
LABEL homepage=$JUDGE0_HOMEPAGE

ENV JUDGE0_SOURCE_CODE "https://github.com/judge0/judge0"
LABEL source_code=$JUDGE0_SOURCE_CODE

ENV JUDGE0_MAINTAINER "Herman Zvonimir Došilović <hermanz.dosilovic@gmail.com>"
LABEL maintainer=$JUDGE0_MAINTAINER

ENV PATH="/usr/local/ruby-2.7.0/bin:/opt/.gem/bin:$PATH"
ENV GEM_HOME="/opt/.gem/"

# Fix Debian Buster apt errors
RUN sed -i 's|http://deb.debian.org|http://archive.debian.org|g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until && \
    apt-get update && \
    apt-get install -y --no-install-recommends cron libpq-dev sudo && \
    rm -rf /var/lib/apt/lists/*

# Setup working directory
WORKDIR /api

# Install Ruby gems
COPY Gemfile* ./
RUN RAILS_ENV=production bundle install

# Setup cron
COPY cron /etc/cron.d
RUN cat /etc/cron.d/* | crontab -

# Copy all application files
COPY . .

# Setup judge0 user permissions
RUN useradd -u 1000 -m -r judge0 && \
    echo "judge0 ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers && \
    chown judge0: /api/tmp/

USER judge0

# Expose the port used by judge0 API
EXPOSE 2358

# Entrypoint and default command
ENTRYPOINT ["/api/docker-entrypoint.sh"]
CMD ["/api/scripts/server"]

# Add version label
ENV JUDGE0_VERSION "1.13.1"
LABEL version=$JUDGE0_VERSION


# Development stage
FROM production AS development
CMD ["sleep", "infinity"]
