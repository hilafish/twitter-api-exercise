FROM mongo

RUN mkdir /html
RUN apt-get update && apt-get -y install cron

# Copy cron-job file to the cron.d directory
COPY cron-job /etc/cron.d/cron-job

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/cron-job

# Apply cron job
RUN crontab /etc/cron.d/cron-job

# Create the log file to be able to check status
RUN touch /var/log/cron.log

# Run the command on container startup
CMD ["cron", "-f"]

