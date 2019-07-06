* * * * * mongoexport -h ${mongo_ip} -d twitterdb -c twitterMessagesDocker -f user.name -o /html/index.html --type=csv >> /var/log/cron.log 2>&1

