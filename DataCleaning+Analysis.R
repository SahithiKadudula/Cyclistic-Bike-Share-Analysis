install.packages("tidyverse")
library(tidyverse)


#Import Datasets
jan_2023 <- read.csv('/Users/Sahithikadudula/Downloads/Google DA PC/1-Case Study/datasets/202301-divvy-tripdata.csv')
feb_2023 <- read.csv('/Users/Sahithikadudula/Downloads/Google DA PC/1-Case Study/datasets/202302-divvy-tripdata.csv')
mar_2023 <- read.csv('/Users/Sahithikadudula/Downloads/Google DA PC/1-Case Study/datasets/202303-divvy-tripdata.csv')
apr_2023 <- read.csv('/Users/Sahithikadudula/Downloads/Google DA PC/1-Case Study/datasets/202304-divvy-tripdata.csv')
may_2023 <- read.csv('/Users/Sahithikadudula/Downloads/Google DA PC/1-Case Study/datasets/202305-divvy-tripdata.csv')
jun_2023 <- read.csv('/Users/Sahithikadudula/Downloads/Google DA PC/1-Case Study/datasets/202306-divvy-tripdata.csv')
jul_2023 <- read.csv('/Users/Sahithikadudula/Downloads/Google DA PC/1-Case Study/datasets/202307-divvy-tripdata.csv')
aug_2023 <- read.csv('/Users/Sahithikadudula/Downloads/Google DA PC/1-Case Study/datasets/202308-divvy-tripdata.csv')
sep_2023 <- read.csv('/Users/Sahithikadudula/Downloads/Google DA PC/1-Case Study/datasets/202309-divvy-tripdata.csv')
oct_2023 <- read.csv('/Users/Sahithikadudula/Downloads/Google DA PC/1-Case Study/datasets/202310-divvy-tripdata.csv')
nov_2023 <- read.csv('/Users/Sahithikadudula/Downloads/Google DA PC/1-Case Study/datasets/202311-divvy-tripdata.csv')
dec_2023 <- read.csv('/Users/Sahithikadudula/Downloads/Google DA PC/1-Case Study/datasets/202312-divvy-tripdata.csv')

#checking for column names in all 12 months data
colnames(jan_2023)
colnames(feb_2023)
colnames(mar_2023)
colnames(apr_2023)
colnames(may_2023)
colnames(jun_2023)
colnames(jul_2023)
colnames(aug_2023)
colnames(sep_2023)
colnames(oct_2023)
colnames(nov_2023)
colnames(dec_2023)

#checking the total number of records from the 12 months data
sum(nrow(jan_2023) + nrow(feb_2023) + nrow(mar_2023) + nrow(apr_2023) + nrow(may_2023) 
    + nrow(jun_2023) + nrow(jul_2023) + nrow(aug_2023) + nrow(sep_2023) + nrow(oct_2023) + nrow(nov_2023) + nrow(dec_2023))

#Combining the 12 months data into single dataset
trip_data <- rbind(jan_2023, feb_2023, mar_2023, apr_2023, may_2023, jun_2023, jul_2023, aug_2023, sep_2023, oct_2023, nov_2023, dec_2023)



View(trip_data)
head(trip_data)
str(trip_data)
dim(trip_data)

#Data Validation and Data Cleaning
#checking for records with missing values (NA)
colSums(is.na(trip_data)) #this shows end_lat and end_long has 6990 missing values

#removing missing values
trip_data_clean <- na.omit(trip_data)

#checking whether missing values are removed or not
colSums(is.na(trip_data_clean))

dim(trip_data_clean) #after removing na's, the data set now contains 5712887 records

#removing duplicates
trip_data_clean <- trip_data_clean %>% 
  distinct()

str(trip_data_clean)

# Check for empty strings across all columns
empty_counts <- sapply(trip_data_clean, function(x) sum(x == "", na.rm = TRUE))
print(empty_counts)

trip_data_clean[trip_data_clean == ""] <- NA
colSums(is.na(trip_data_clean))

trip_data_clean <- na.omit(trip_data_clean)
colSums(is.na(trip_data_clean))

dim(trip_data_clean)

# Extracting the time (hours, minutes, and seconds) from started_at and ended_at
#trip_data_clean$start_time <- format(trip_data_clean$started_at, format = "%H:%M:%S")
#trip_data_clean$end_time <- format(trip_data_clean$ended_at, format = "%H:%M:%S")

# Keeping only the date part in started_at and ended_at columns
#trip_data_clean$started_at <- format(trip_data_clean$started_at, format = "%Y-%m-%d")
#trip_data_clean$ended_at <- format(trip_data_clean$ended_at, format = "%Y-%m-%d")

# Verifying the new columns
#head(trip_data_clean[, c("started_at", "start_time", "ended_at", "end_time")])

# Convert 'started_at' and 'ended_at' columns to datetime format
#trip_data_clean$started_at <- as.POSIXct(trip_data_clean$started_at, format = "%Y-%m-%d %H:%M:%S")
#trip_data_clean$ended_at <- as.POSIXct(trip_data_clean$ended_at, format = "%Y-%m-%d %H:%M:%S")

# Check the structure again to verify the changes
#str(trip_data_clean)


#renaming rideable_type(types of bike - electric, classic), member_casual(riders - member, casual) to meaningful column names
trip_data_clean <- trip_data_clean %>% 
  rename(
    bike_type = rideable_type,
    rider = member_casual
  )

colnames(trip_data_clean)
str(trip_data_clean)

# Calculate the time difference between started_at and ended_at
trip_data_clean$ride_length <- difftime(trip_data_clean$ended_at, trip_data_clean$started_at, units = "mins")

# Verifying the new ride_length column
head(trip_data_clean[, c("started_at", "ended_at", "ride_length")])

View(trip_data_clean)

# Convert started_at and ended_at to POSIXct format
trip_data_clean$started_at <- as.POSIXct(trip_data_clean$started_at, format = "%Y-%m-%d %H:%M:%S")
trip_data_clean$ended_at <- as.POSIXct(trip_data_clean$ended_at, format = "%Y-%m-%d %H:%M:%S")

# Recalculate ride_length as a difftime object
trip_data_clean$ride_length <- difftime(trip_data_clean$ended_at, trip_data_clean$started_at, units = "mins")

# Force ride_length to be stored as a difftime object
trip_data_clean$ride_length <- as.difftime(trip_data_clean$ride_length, units = "mins")



# Verify the changes
str(trip_data_clean)


#Create a column called day_of_week, and calculate the day of the week that each ride started
# Use the format function to directly get Sunday = 1, Monday = 2, ..., Saturday = 7, The modulo operation (%% 7 + 1) shifts the values so that Sunday becomes 1, and Monday becomes 2,
#trip_data_clean$day_of_week <- as.numeric(format(trip_data_clean$started_at, "%u")) %% 7 + 1

# View the first few rows to verify
#head(trip_data_clean$day_of_week)

# Save the dataframe as a CSV file to your local machine
write.csv(trip_data_clean, "/Users/Sahithikadudula/Downloads/Google DA PC/1-Case Study/trip_data_clean.csv", row.names = FALSE)





