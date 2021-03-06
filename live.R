## load packages
library(rtweet)

## install and load ggplot
if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2")
library(ggplot2)

## install gridExtra
if (!requireNamespace("gridExtra", quietly = TRUE)) install.packages("gridExtra")

## table output function
tab_sort <- function (x, n = 10, mentions = FALSE) {
  sumrow <- data.frame(
    "screen_name" = paste(length(unique(x)), "users"),
    "n_tweets" = length(x),
    "prop_tweets" = 1.000,
    stringsAsFactors = FALSE
  )
  x <- sort(table(x), decreasing = TRUE)
  x <- data.frame(
    "screen_name" = names(x),
    "n_tweets" = as.integer(x),
    stringsAsFactors = FALSE
  )
  x$prop_tweets <- x$n_tweets / sum(x$n_tweets, na.rm = TRUE)
  x$prop_tweets <- round(x$prop_tweets, 3)
  x <- head(x, n)
  x <- rbind(x, sumrow)
  row.names(x) <- c(seq_len(nrow(x) - 1L), "total")
  if (mentions) {
    names(x)[2:3] <- c("n_mentions", "prop_mentions")
  }
  x
}

## function for cleaning text and creating word freq table
clean_text_table <- function(data) {
  txt <- tolower(plain_tweets(data$text))
  txt <- gsub("&amp;", "", txt)
  txt <- gsub("#nca17", "", txt, ignore.case = TRUE)
  txt <- unlist(strsplit(txt, " "))
  txt <- gsub("^[[:punct:]]{1,}|[[:punct:]]{1,}$", "", txt)
  txt <- trimws(txt)
  txt <- txt[txt != ""]
  swds <- stopwordslangs$word[stopwordslangs$lang == "en" & stopwordslangs$p > .99]
  txt <- txt[!txt %in% swds]
  sort(table(txt), decreasing = TRUE)
}

## counter
i <- 1L

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
  ts_plot(nca, "hours") +
    theme_minimal(base_family = "sans") +
    theme(plot.title = element_text(face = "bold")) +
    labs(x = NULL, y = NULL, title = "Time series of #NCA17 Twitter statuses",
         subtitle = "Twitter statuses aggregated by hour",
         caption = "\nData collected from Twitter's stream (filter) API using rtweet") +
    ggsave("nca17-ts.png", width = 8, height = 6, units = "in")

  ## most frequent tweeters table
  usrs <- tab_sort(nca$screen_name)
  png("nca17-usrs.png", height = 3.1, width = 4.25, "in", res = 300)
  par(bg = "white")
  gridExtra::grid.table(usrs, theme = gridExtra::ttheme_default(base_size = 9))
  dev.off()

  ## most frequent mentions table
  naomit <- function(x) x[!is.na(x)]
  usrs <- tab_sort(naomit(unlist(nca$mentions_screen_name)), mentions = TRUE)
  png("nca17-ats.png", height = 3.1, width = 4.25, "in", res = 300)
  par(bg = "white")
  gridExtra::grid.table(usrs, theme = gridExtra::ttheme_default(base_size = 9))
  dev.off()

  ## create frequency table for popular words
  wds <- clean_text_table(nca)
  minfreq <- quantile(as.double(wds), .75)

  png("nca17-wc.png", height = 8, width = 8, "in", res = 300)
  par(bg = "black")
  wordcloud::wordcloud(
    names(wds),
    as.integer(wds),
    min.freq = minfreq,
    random.color = FALSE,
    random.order = FALSE,
    colors = gg_cols(6)
  )
  dev.off()

  ## update git repo (this is from my own utils R package)
  tfse::rm_.DS_Store()
  tfse::add_to_git(paste("live update number", i), interactive = FALSE)
  i <- i + 1L

  ## sleep for hour
  Sys.sleep(60L * 60L)
}
