## NCA17 tweets

## install and load rtweet
if (!requireNamespace("devtools", quietly = TRUE)) install.packages("devtools")
devtools::install_github("mkearney/rtweet")

## install and load ggplot
if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2")
library(ggplot2)

## create data folder is it doesn't already exist
if (!dir.exists("data")) dir.create("data")

## while loop for live updating
while (Sys.time() < as.POSIXct("2017-11-21")) {
  ## download stream data, save it to data folder
  download.file(
    "https://www.dropbox.com/s/t0sefc0lzqbwd32/stream-1.json?dl=1",
    "data/nca17.json"
  )

  ## read in stream data, converting it to data frame
  nca <- parse_stream("data/nca17.json")

  ## plot the time series of #NCA17 activity
  ts_plot(nca, "mins") +
    theme_minimal(base_family = "sans") +
    theme(plot.title = element_text(face = "bold")) +
    labs(x = NULL, y = NULL, title = "Time series of #NCA17 Twitter statuses",
         subtitle = "Twitter statuses aggregated by minute",
         caption = "\nData collected from Twitter's stream (filter) API using rtweet") +
    ggsave("nca17-ts.png", width = 8, height = 6, units = "in")

  ## sleep for hour
  Sys.sleep(60L * 60L)
}
