FROM node:5.5.0
# Install deps
RUN apt-get update -qq && apt-get install -y build-essential
# Setup app directory
RUN mkdir /vestorly-vesty
WORKDIR /vestorly-vesty
COPY package.json /vestorly-vesty/package.json
# Install node deps
RUN npm cache clean
RUN rm -rf node_modules tmp dist
RUN npm install
# Copy rest of the repo
COPY . /vestorly-vesty
# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# Run bot
ENTRYPOINT /vestorly-vesty/bin/hubot -a slack
