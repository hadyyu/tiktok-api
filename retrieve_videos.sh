#!/bin/bash

# Your access token
access_token="your_access_token"

# Specify the desired output directory path
output_dir="/d/video_data"

# Specify the region code and hashtag name
region_code="NL"
hashtag_name="rotterdammarkthal"

# Specify the start year and month
start_year="2023"
start_month="10"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop through each day of the specified month
for day in {01..31}; do
    # Format the current day with leading zeros
    formatted_day=$(printf "%02d" "$day")

    # Set the start and end dates for the current day
    start_date="${start_year}${start_month}${formatted_day}"
    end_date="${start_date}"

    # Perform the initial request to get search_id
    initial_response=$(curl -L -X POST 'https://open.tiktokapis.com/v2/research/video/query/?fields=id,video_description,create_time,share_count,view_count,like_count,comment_count,music_id,hashtag_names,effect_ids,playlist_id,voice_to_text,username' \
        -H "Authorization: Bearer $access_token" \
        -H 'Content-Type: application/json' \
        --data-raw '{
            "query": {
                "and": [
                    {
                        "operation": "IN",
                        "field_name": "region_code",
                        "field_values": ["'"$region_code"'"]
                    },
                    {
                        "operation":"EQ",
                        "field_name":"hashtag_name",
                        "field_values":["'"$hashtag_name"'"]
                    }
                ]
            },
            "max_count": 100,
            "cursor": 0,
            "start_date": "'"$start_date"'",
            "end_date": "'"$end_date"'"
        }')

    # Extract search_id from the initial response
    search_id=$(jq -r '.data.search_id' <<< "$initial_response")

    # Initialize cursor to 0
    cursor=0

    # Loop through subsequent requests using the retrieved search_id
    while true; do
        response=$(curl -L -X POST 'https://open.tiktokapis.com/v2/research/video/query/?fields=id,video_description,create_time,share_count,view_count,like_count,comment_count,music_id,hashtag_names,effect_ids,playlist_id,voice_to_text,username' \
            -H "Authorization: Bearer $access_token" \
            -H 'Content-Type: application/json' \
            --data-raw '{
                "query": {
                    "and": [
                        {
                            "operation": "IN",
                            "field_name": "region_code",
                            "field_values": ["'"$region_code"'"]
                        },
                        {
                            "operation":"EQ",
                            "field_name":"hashtag_name",
                            "field_values":["'"$hashtag_name"'"]
                        }
                    ]
                },
                "max_count": 100,
                "cursor": '$cursor',
                "start_date": "'"$start_date"'",
                "end_date": "'"$end_date"'",
                "search_id":"'"$search_id"'"
            }')

        # Check if there is data in the response
        if [ "$(jq '.data | length' <<< "$response")" -eq 0 ]; then
            # No more data, break out of the loop
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

        # Append the entire data to the output file
        output_file="$output_dir/${hashtag_name}_${start_date}.json"
        echo "$response" >> "$output_file"

        # Log the size of the output file
        file_size=$(wc -c < "$output_file")
        echo "File size of $output_file: $file_size bytes"

        # Check if there is more data
        has_more=$(jq -r '.data.has_more' <<< "$response")

        # If there is more data, update the cursor
        if [ "$has_more" == "true" ]; then
            cursor=$(jq -r '.data.cursor' <<< "$response")
        else
            # No more data, break out of the loop
            break
        fi

        # Sleep for 1 second between requests
        sleep 1
    done
done

