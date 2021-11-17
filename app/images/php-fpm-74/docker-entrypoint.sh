#!/bin/bash

# Configure sendmail
sendmailConfigured=$(grep 'noreply@dev.localhost' /etc/hosts)
if [ -z "$sendmailConfigured" ]; then
    # add host to /etc/hosts
    host=$(hostname)
    line=$(cat /etc/hosts | grep $host)
    echo "$line noreply@dev.localhost" >> /etc/hosts

    echo "$host" >> /etc/mail/relay-domains

    # Make sure that sendmail does not error out if we spoof an email.
    #
    # This: www-data set sender to belazor@icloud.com using -f
    # Would result in an error:
    # (reason: 553 5.1.8 <belazor@icloud.com>... Domain of sender address belazor@icloud.com does not exist)
    #
    lineNumber=$(grep -n -m1 'dnl # Default Mailer setup' /etc/mail/sendmail.mc | cut -d ':' -f1)
    sed -i "${lineNumber}iFEATURE(\`accept_unresolvable_domains')dnl" /etc/mail/sendmail.mc
    sed -i "${lineNumber}idnl # Accept unresolvable domains" /etc/mail/sendmail.mc

    m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf
fi

# Start sendmail
sendmail -bd

# Reload certificates so that everything in /usr/local/share/ca-certificates is loaded.
update-ca-certificates

# Start rsyslogd
rsyslogd
# Send syslog to docker logs
tail -f -n0 /var/log/syslog &
# Start php-fpm
php-fpm
