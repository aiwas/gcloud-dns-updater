#!/bin/bash

# update.sh
# Update dns records through gcloud sdk, invoked by gcloud-dns-updater.service
# Author: Miyako Kuwano <aiwas@arg.vc>

send_discord () {
        curl -s -X POST -H "Content-Type: application/json" -d "{\"content\": \"${1}\"}" $DISCORD_WEBHOOK
}

# load settings
. $(cd $(dirname $0); pwd)/updater.conf
EXTERNAL_IP_ANSWERER="http://ifconfig.me"

gcloud config set account ${GCP_SERVICE_ACCOUNT} > /dev/null 2>&1
gcloud config set project ${GCP_PROJECT_ID} > /dev/null 2>&1

RECORD_IP=$(gcloud dns record-sets list --zone=${DNS_ZONE} --name=${DNS_DOMAIN} --type=A | grep "${DNS_DOMAIN}" | awk '{ print $4 }')
CURRENT_IP=$(curl -s ${EXTERNAL_IP_ANSWERER})

echo "In A record      = $RECORD_IP"
echo "Actual ephemeral = $CURRENT_IP"
if [ "$CURRENT_IP" != "$RECORD_IP" ]; then
        send_discord "IP address seems to have changed. $RECORD_IP -> $CURRENT_IP"

        gcloud dns record-sets transaction start --zone=${DNS_ZONE}

        gcloud dns record-sets transaction remove --zone=${DNS_ZONE} --name=${DNS_DOMAIN} --type=A
        gcloud dns record-sets transaction add --zone=${DNS_ZONE} --name=${DNS_DOMAIN} --type=A --ttl=300 "${CURRENT_IP}"

        gcloud dns record-sets transaction execute --zone=${DNS_ZONE} && \
        send_discord "Updating DNS completed successfully.\nCurrent global IP address: $CURRENT_IP"
else
        echo "IP address has not changed. (Current global IP address: $CURRENT_IP)"
fi
