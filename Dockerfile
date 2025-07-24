FROM ubuntu:20.04 AS base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl gnupg2 sudo lsb-release git unzip \
    && rm -rf /var/lib/apt/lists/*

# Add Judge0 PPA and base setup
RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y

# Set working dir
WORKDIR /judge0

# Install core dependencies (language runtimes: C++, Java, Python, JavaScript)
RUN apt-get update && apt-get install -y \
    build-essential gcc g++ \
    openjdk-17-jdk \
    python3 python3-pip \
    nodejs npm \
    libpq-dev cron ruby ruby-dev \
    && rm -rf /var/lib/apt/lists/*

# Set up Ruby
ENV PATH="/usr/local/ruby-2.7.0/bin:/opt/.gem/bin:$PATH"
ENV GEM_HOME="/opt/.gem/"

# Add judge0 user
RUN useradd -u 1000 -m -r judge0 && \
    echo "judge0 ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers

# Setup working directory
WORKDIR /api

# Copy app files
COPY . .

# Install Ruby dependencies
RUN gem install bundler && bundle install

# Set ownership
RUN chown -R judge0:judge0 /api && chmod +x /api/scripts/server

# Copy crons
COPY cron /etc/cron.d
RUN cat /etc/cron.d/* | crontab -

USER judge0

# Expose port
EXPOSE 2358

ENTRYPOINT ["/api/docker-entrypoint.sh"]
CMD ["/api/scripts/server"]
