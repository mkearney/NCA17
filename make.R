## NCA17 tweets

## install and load rtweet
if (!requireNamespace("devtools", quietly = TRUE)) install.packages("devtools")
devtools::install_github("mkearney/rtweet")
library(rtweet)

## create data folder is it doesn't already exist
if (!dir.exists("data")) dir.create("data")

## download stream data, save it to data folder
download.file(
  "https://www.dropbox.com/s/t0sefc0lzqbwd32/stream-1.json?dl=1",
  "data/nca17.json"
)

## read in stream data, converting it to data frame
nca <- parse_stream("data/nca17.json")
