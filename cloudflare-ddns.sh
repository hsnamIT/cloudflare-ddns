#!/bin/bash

echo "Running script at $(date)"

## Define your Cloudflare API key and email
CLOUDFLARE_API_KEY=XXX
CLOUDFLARE_EMAIL=test@gmail.com

## Define the domain and record you want to update
DOMAIN=domain.cloud
RECORD=A

## Get the current public IP address
IP=$(curl -s https://cloudflare.com/cdn-cgi/trace | grep -E '^ip' | cut -d = -f 2)
echo "The current public IP address: $IP"

## Get all zones and find the one matching the domain => get the target zoneID
ALL_ZONES=$(curl -s https://api.cloudflare.com/client/v4/zones/ \
  -H "Authorization: Bearer $CLOUDFLARE_API_KEY" \
  -H "Content-Type: application/json" )

## Get an A record, extract the current IP
ZONE_ID=$(echo "$ALL_ZONES" | jq -r --arg name "$DOMAIN" '.result[] | select(.name == $name) | .id')
echo "Target zone ID: $ZONE_ID"

## Get the current IP address on Cloudflare
ALL_DNS_RECORDS=$(curl -s https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records \
  -H "Authorization: Bearer $CLOUDFLARE_API_KEY" \
  -H "Content-Type: application/json" )

A_RECORDS=$(echo "$ALL_DNS_RECORDS" | jq -c '[.result[] | select(.type == "A")]')

CF_IP=$(echo "$A_RECORDS" | jq -r '.[0].content')
echo "IP registered on DNS: $CF_IP"

# Update the IP address on Cloudflare if it has changed
if [ "$IP" != "$CF_IP" ]; then
  # Iterate over A_RECORDS and update new IP with this API
  echo "$A_RECORDS" | jq -c '.[]' | while read -r record; do
  RECORD_ID=$(echo "$record" | jq -r '.id')
  RECORD_NAME=$(echo "$record" | jq -r '.name')

  echo "Updating $RECORD_ID - $RECORD_NAME"
  curl -s https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID \
    -X PATCH \
    -H "Authorization: Bearer $CLOUDFLARE_API_KEY" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"A\",\"name\":\"$RECORD_NAME\",\"content\":\"$IP\"}"

  echo "Finish updating $RECORD_ID - $RECORD_NAME"
done
fi
