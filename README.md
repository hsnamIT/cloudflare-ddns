# cloudflare-ddns
A simple script to check and update all DNS records A on  Cloudflare with the latest home server public IP every 5 mins

Cloudflare API token with the Zone scope is required

## Build an image and start a container in detached mode
`docker compose up --build -d`

## Stop the container
`docker compose down`

