#!/bin/bash

# Your access token
access_token="your_access_token"

# Specify the desired output directory path
output_dir="/d/user_data"

# Array of usernames
usernames=("a" "b" "c" "d")

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop through each username
for username in "${usernames[@]}"; do
    # Perform the request to get user info
    response=$(curl -L 'https://open.tiktokapis.com/v2/research/user/info/?fields=display_name,bio_description,avatar_url,is_verified,follower_count,following_count,likes_count,video_count' \
        -H "Authorization: Bearer $access_token" \
        -H 'Content-Type:application/json' \
        -d '{"username": "'"$username"'" }')

    # Check if the response contains an error
    error=$(jq -r '.error.message' <<< "$response")
    if [ ! -z "$error" ]; then
        echo "Error querying user $username: $error"
        continue
    fi

    # Write response to a file
    output_file="$output_dir/${username}_info.json"
    echo "$response" > "$output_file"
    echo "User info saved to: $output_file"
done
