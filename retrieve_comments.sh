#!/bin/bash

# Your access token
access_token="your_access_token"

# Specify the desired output directory path
output_dir="/d/comment_data"

# Video IDs to loop through 

video_ids=("7334675108738518304" "7335405338553748768" "7335916831405804832" "7338059730541137184" "7339127058552999200" "7339997216918031649" "7295832020364709153" "7301768809319304481" "7303958678540012833" "7304270926550404384" "7306860218388974880" "7314738618931645729" "7317605164284644641" "7319846262201748768" "7322451819253271841" "7323901065378811169" "7325067350175223072" "7327682063027408161" "7330214692465462560")

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop through video IDs
for video_id in "${video_ids[@]}"; do
    output_file="/d/comment_data/comments_$video_id.json"

    # Initialize cursor to 0
    cursor=0

    while true; do
        response=$(curl -L -X POST "https://open.tiktokapis.com/v2/research/video/comment/list/?fields=id,like_count,create_time,text,video_id,parent_comment_id" \
            -H "Authorization: Bearer $access_token" \
            -H "Content-Type: application/json" \
            -d '{"video_id": "'$video_id'","max_count":100,"cursor":'$cursor'}')

        # Check if there are comments in the response
        if [ "$(jq '.data.comments | length' <<< "$response")" -eq 0 ]; then
            # No more comments, break out of the loop
            break
        fi

        # Check for errors in API response
        error_code=$(jq -r '.error_code' <<< "$response")
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
    file_size=$(wc -c < "$output_file")
    echo "File size of $output_file: $file_size bytes"

    # Append a newline to the output file
    echo "" >> "$output_file"

    echo "Comments for video ID $video_id saved to $output_file"
done

