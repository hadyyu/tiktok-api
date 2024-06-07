curl --location --request POST 'https://open.tiktokapis.com/v2/oauth/token/'  \
--header 'Content-Type: application/x-www-form-urlencoded' \
--header 'Cache-Control: no-cache' \
--data-urlencode 'client_key='${CLIENT_KEY}'' \
--data-urlencode 'client_secret='${CLIENT_SECRET}'' \
--data-urlencode 'grant_type=client_credentials' 