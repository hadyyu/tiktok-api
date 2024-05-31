#!/bin/bash

# Your access token
access_token="${ACCESS_TOKEN}"

# Specify the desired output directory path
output_dir="/d/comment_data"

# Read video IDs from the file into an array
video_ids=()
while IFS= read -r line; do
    video_ids+=("$line")
done < video_ids.txt

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Function to get comments for a given video ID
get_comments() {
    local video_id=$1
    local output_file="$output_dir/comments_$video_id.json"
    local cursor=0

    while true; do
        local response=$(curl -L -X POST "https://open.tiktokapis.com/v2/research/video/comment/list/?fields=id,like_count,create_time,text,video_id,parent_comment_id" \
            -H "Authorization: Bearer $access_token" \
            -H "Content-Type: application/json" \
            -d '{"video_id": "'$video_id'","max_count":100,"cursor":'$cursor'}')

        # Check if there are comments in the response
        if [ "$(jq '.data.comments | length' <<< "$response")" -eq 0 ]; then
            # No more comments, break out of the loop
            break
        fi

        # Check for errors in API response
        local error_code=$(jq -r '.error_code' <<< "$response")
        if [ "$error_code" != "null" ]; then
            echo "Error in API response: $error_code"
            # Handle the error, e.g., exit the loop or script
            break
        fi

        # Process JSON response using jq
        # Append the entire comment data to the output file
        echo "$response" >> "$output_file"

        # Get the next cursor for the next request
        cursor=$(jq -r '.data.cursor' <<< "$response")

        # Check if the cursor is empty or null, and exit the loop if true
        if [ -z "$cursor" ] || [ "$cursor" == "null" ]; then
            break
        fi

        # Sleep for 1 second between requests
        sleep 1
    done

    # Log the size of the output file
    local file_size=$(wc -c < "$output_file")
    echo "File size of $output_file: $file_size bytes"

    # Append a newline to the output file
    echo "" >> "$output_file"

    echo "Comments for video ID $video_id saved to $output_file"
}

# Loop through video IDs and get comments
for video_id in "${video_ids[@]}"; do
    get_comments "$video_id"
done

