FROM ubuntu:20.04 AS base

ENV DEBIAN_FRONTEND=noninteractive

# Base dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl gnupg2 sudo lsb-release git unzip \
    build-essential gcc g++ \
    openjdk-17-jdk \
    python3 python3-pip \
    nodejs npm \
    libpq-dev cron ruby ruby-dev \
    && rm -rf /var/lib/apt/lists/*

# Set environment paths for Ruby
ENV GEM_HOME="/opt/.gem/"
ENV PATH="$GEM_HOME/bin:$PATH"

# Create a non-root user
RUN useradd -u 1000 -m -r judge0 && \
    echo "judge0 ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers

# Set working directory
WORKDIR /api

# Copy app files
COPY . .

# Install Ruby dependencies compatible with Ruby 2.7
RUN gem install bundler -v 2.4.22 && \
    gem install mini_portile2 -v 2.8.5 && \
    bundle _2.4.22_ install

# Set permissions
RUN chown -R judge0:judge0 /api && chmod +x /api/scripts/server

# Setup crons
COPY cron /etc/cron.d
RUN cat /etc/cron.d/* | crontab -

USER judge0

# Expose Judge0 API port
EXPOSE 2358

# Entrypoint and server start
ENTRYPOINT ["/api/docker-entrypoint.sh"]
CMD ["/api/scripts/server"]
