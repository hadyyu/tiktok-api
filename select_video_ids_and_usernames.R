library(jsonlite)
library(tidyverse)
library(here)
options(scipen = 999)


###1. Clean json files of video information to the right format
##1.1 Add commas to create the right format json files
# Replace 'folder_path' with your actual folder path
folder_path <- "your_folder_path"

# List all JSON files in the folder
input_files <- list.files(path = folder_path, pattern = "\\.json$", full.names = TRUE)

# Create output file names
output_files <- gsub("\\.json$", "_new.json", input_files)

# Process each input file
for (i in seq_along(input_files)) {
  # Read the content of the input file
  json_content <- paste(readLines(input_files[i], warn = FALSE), collapse = "\n")
  
  # Add commas between JSON objects
  json_content_fixed <- gsub("(}\\s*\\{)", "},\n{", json_content)
  
  # Wrap the content in square brackets to create an array
  json_content_wrapped <- paste("[", json_content_fixed, "]", sep = "")
  
  # Write the modified content to a new JSON file
  writeLines(json_content_wrapped, output_files[i])
}
# Delete the old json file and only leave the "_new.json" files


###2. Transfer json files to data frame
##2.1 Create json lists
folder_path <- "your_folder_path"
file_paths <- list.files(path = folder_path, pattern = "\\.json$", full.names = TRUE)

json_list <- lapply(file_paths, function(file) {
  fromJSON(file, bigint_as_char = TRUE)
})

json_list %>% glimpse()

data_list <- map(json_list, "data")
videos_list <- map(data_list, "videos")

##2.2 Some lists do not have the items such as playlist_id, effect_ids, music_id, you need to create them if do not have, then bind them.
# Iterate through each sublist in videos_list
for (i in seq_along(videos_list)) {
  # Check if the current sublist is a list
  if (is.list(videos_list[[i]])) {
    # Iterate through each element in the sublist
    for (j in seq_along(videos_list[[i]])) {
      # Check if the current element is a data frame and not empty
      if (is.data.frame(videos_list[[i]][[j]]) && nrow(videos_list[[i]][[j]]) > 0) {
        # Check if the playlist_id column exists
        if (!("playlist_id" %in% names(videos_list[[i]][[j]]))) {
          # Add the playlist_id column with default value or NA
          videos_list[[i]][[j]]$playlist_id <- NA  # You can replace NA with a default value if needed
        } else if (class(videos_list[[i]][[j]]$playlist_id) != "character") {
          # Convert playlist_id column to character if it's not already
          videos_list[[i]][[j]]$playlist_id <- as.character(videos_list[[i]][[j]]$playlist_id)
        }
      }
    }
  }
}

# Iterate through each sublist in videos_list
for (i in seq_along(videos_list)) {
  # Check if the current sublist is a list
  if (is.list(videos_list[[i]])) {
    # Iterate through each element in the sublist
    for (j in seq_along(videos_list[[i]])) {
      # Check if the current element is a data frame and not empty
      if (is.data.frame(videos_list[[i]][[j]]) && nrow(videos_list[[i]][[j]]) > 0) {
        # Check if the effect_ids column exists
        if (!("effect_ids" %in% names(videos_list[[i]][[j]]))) {
          # Create the effect_ids column with value "0" as a list
          videos_list[[i]][[j]]$effect_ids <- list("0")
        } else if (class(videos_list[[i]][[j]]$effect_ids) != "list") {
          # Convert effect_ids column to list if it's not already
          videos_list[[i]][[j]]$effect_ids <- list(videos_list[[i]][[j]]$effect_ids)
        }
      }
    }
  }
}

# Iterate through each sublist in videos_list
for (i in seq_along(videos_list)) {
  # Check if the current sublist is a list
  if (is.list(videos_list[[i]])) {
    # Iterate through each element in the sublist
    for (j in seq_along(videos_list[[i]])) {
      # Check if the current element is a data frame and not empty
      if (is.data.frame(videos_list[[i]][[j]]) && nrow(videos_list[[i]][[j]]) > 0) {
        # Check if the music_id column exists
        if (!("music_id" %in% names(videos_list[[i]][[j]]))) {
          # Create the music_id column with value "0" as a list
          videos_list[[i]][[j]]$music_id <- list("0")
        } else if (class(videos_list[[i]][[j]]$music_id) != "list") {
          # Convert music_id column to list if it's not already
          videos_list[[i]][[j]]$music_id <- list(videos_list[[i]][[j]]$music_id)
        }
      }
    }
  }
}

##2.3 Filter out sublists with length 0, null values
# Filter out sublists with length 0 or containing non-data frame elements
videos_list_filtered <- lapply(videos_list, function(list) {
  if (length(list) > 0 && all(sapply(list, is.data.frame))) {
    list
  } else {
    NULL
  }
})

# Filter out NULL values
videos_list_filtered <- Filter(Negate(is.null), videos_list_filtered)

# Check if there are any non-empty sublists left
if (length(videos_list_filtered) > 0) {
  # Combine the remaining non-empty sublists into a single data frame
  combined_data <- bind_rows(videos_list_filtered)
} else {
  # If there are no non-empty sublists left, assign NULL to combined_data
  combined_data <- NULL
}

##2.4 Combine all the json lists to one data frame
combined_data_video <- bind_rows(videos_list_filtered)
print(combined_data_video)

### 3. Generate URLs
df <- combined_data_video
df$url <- paste("https://www.tiktok.com/@", df$username, "/video/", df$id, sep = "")

### 4. Write dataframe to CSV file
# Concatenate list elements into a single string separated by commas
str(df)
df$hashtag_names <- sapply(df$hashtag_names, function(lst) paste(lst, collapse = ","))
df$effect_ids <- sapply(df$effect_ids, function(lst) paste(lst, collapse = ","))
df$music_id <- sapply(df$music_id, function(lst) paste(lst, collapse = ","))
# Write dataframe to CSV file
write.csv(df, "your_output_file_path", row.names = FALSE)

### 5. Select video_ids for retrieving comments
##5.1 Select video_ids with comments amount > 0
combined_data_with_comments <- 
  combined_data_video %>% 
  filter(comment_count > 0)

##5.2 Seperate video_ids to the groups of 100 ids for preparation of retrieving comments
breaks <- seq(100, round(nrow(combined_data_with_comments), -2) + 100, by = 100)
id_list <- vector("list", length = round(nrow(combined_data_with_comments)/100 + 1, 0))
for (i in breaks) {
  # print(paste("IDs:", i - 100 + 1, "to", i))
  # print(format(combined_data_with_comments[(i - 100 + 1): i, "id"], scientific = FALSE))
  id_list[[i / 100]] <- format(combined_data_with_comments[(i - 100 + 1): i, "id"], scientific = FALSE)
  cat(paste0("\"", id_list[[i / 100]], "\""), "\n\n")
}

# Paste the 100 video_ids 

### 6. Select usernames for retrieving users
## 6.1 Select usernames from the username column
usernames <- df$username

## 6.2 Remove duplicate usernames
unique_usernames <- unique(usernames)
text <- paste0('"', unique_usernames, '"', collapse = " ")
cat(text)

# Paste the usernames

