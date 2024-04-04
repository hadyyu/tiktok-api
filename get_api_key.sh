curl --location --request POST 'https://open.tiktokapis.com/v2/oauth/token/'  \
--header 'Content-Type: application/x-www-form-urlencoded' \
--header 'Cache-Control: no-cache' \
--data-urlencode 'client_key=your_client_key' \
--data-urlencode 'client_secret=your_client_secret' \
--data-urlencode 'grant_type=client_credentials' 
