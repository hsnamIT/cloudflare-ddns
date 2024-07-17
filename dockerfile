FROM ubuntu:latest

# Install cron and other necessary packages
RUN apt-get update && apt-get install -y cron curl jq

# Copy the bash script into the container
COPY cloudflare-ddns.sh /usr/local/bin/cloudflare-ddns.sh
RUN chmod +x /usr/local/bin/cloudflare-ddns.sh

# Verify the script exists and is executable
RUN ls -l /usr/local/bin/cloudflare-ddns.sh

# Create a cron job
RUN echo "*/5 * * * * /usr/local/bin/cloudflare-ddns.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/my-cron-job

# Apply cron job and start cron service
RUN crontab /etc/cron.d/my-cron-job

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Run the command on container startup
CMD cron && tail -f /var/log/cron.log
