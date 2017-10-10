FROM anapsix/alpine-java:8u144b01_server-jre
MAINTAINER Andy Choi <choibc@gmail.com>

# Configuration
ENV JIRA_HOME /data/jira
ENV JIRA_VERSION 7.5.0

# Install dependencies
RUN apk upgrade --update \
	&& apk add --update curl	tar \
	&& apk add xmlstarlet --update --repository http://dl-3.alpinelinux.org/alpine/edge/testing/   

# Create the user that will run the jira instance and his home directory (also make sure that the parent directory exists)
RUN mkdir -p $(dirname $JIRA_HOME) \
	&& adduser -h $JIRA_HOME -s /bin/bash -u 547 -D jira
	

# Download and install jira in /opt with proper permissions and clean unnecessary files
RUN curl -Lks https://downloads.atlassian.com/software/jira/downloads/atlassian-jira-core-$JIRA_VERSION.tar.gz -o /tmp/jira.tar.gz \
	&& mkdir -p /opt/jira \
	&& tar -zxf /tmp/jira.tar.gz --strip=1 -C /opt/jira \
	&& chown -R root:root /opt/jira \
	&& chown -R 547:root /opt/jira/logs /opt/jira/temp /opt/jira/work \
	&& rm /tmp/jira.tar.gz

# Add jira customizer and launcher
COPY launch.sh /launch

# Make jira customizer and launcher executable
RUN chmod +x /launch

# Expose ports
EXPOSE 8080

# Workdir
WORKDIR /opt/jira

# Launch jira
ENTRYPOINT ["/launch"]
