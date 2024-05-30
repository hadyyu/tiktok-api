# A guide for retrieving social media data from TikTok research API
The aim of this repository is to help researchers to retrieve three categories of social media data: 1) video information, 2) video comments and 3) user information through TikTok research API.

## Content
This repository is composed of:
- Json and shell codes to retrieve data from API
- R scripts to transfer json lists to dataframe and to select video_ids and usernames for preparation of other retrieving task.
- the eviromment needed for using the API such as personal client key, secret and access token.

## How to use this repository
### Step 1: Apply for the TikTok research API
You should apply for the TikTok research API on the [TikTok Developer Portal](https://developers.tiktok.com/products/research-api/) and follow the instructions. After their approval, you will get the personal client key and client secret. 

### Step 2: Get API key 
You can use [get_api_key.sh](https://github.com/hadyyu/tiktok-api/blob/main/get_api_key.sh) in git bash or other terminals to generate your personal access token, please notice that this key is only valiable for 2 hours and will expire after 2 hours, you can generate a new one if needed.

### Step 3: Test API key and environment
Use [test.json](https://github.com/hadyyu/tiktok-api/blob/main/test.json) to test your personal api key and three catogories of data retrieving, if there are data from respose, your key are successfully working, If you have any error, please check [Frequently Asked Questions](https://developers.tiktok.com/doc/research-api-faq/)

### Step 4: Retrieve video information
You can use [retrieve_videos.sh](https://github.com/hadyyu/tiktok-api/blob/main/retrieve_videos.sh) to retrieve video information, please replace your personal access token and your search parameters based on the API reference of [Query Videos](https://developers.tiktok.com/doc/research-api-specs-query-videos/)

### Step 5: Transfer json files to dataframe and select video_ids and usernames for furture steps
Here providing R scripts to clean and process the data. Use [select_video_ids_and_usernames.R](https://github.com/hadyyu/tiktok-api/blob/main/select_video_ids_and_usernames.R) to clean and combine multiple json lists to one dataframe, and extract the video_ids for retrieving comments and usernames for retrieving user information.

### Step 6: Retrieve comments of videos
You can use [retrieve_comments.sh](https://github.com/hadyyu/tiktok-api/blob/main/retrieve_comments.sh) to retrieve comments of videos, please replace your personal access token and your search parameters based on the API reference of [Query Video Comments](https://developers.tiktok.com/doc/research-api-specs-query-video-comments/)

### Step 7: Retrieve users information
You can use [retrieve_users.sh](https://github.com/hadyyu/tiktok-api/blob/main/retrieve_users.sh) to retrieve users information, please replace your personal access token and your search parameters based on the API reference of [Query User Info](https://developers.tiktok.com/doc/research-api-specs-query-user-info/)

## API Version
The TikTok research API Version is the newest from 05/16/2024, please frequently check the [Changelog](https://developers.tiktok.com/doc/changelog/) to see if there are any updates.

## License and citation
This repository is licensed under MIT License.

Please cite this repository as:
@ TO DO
