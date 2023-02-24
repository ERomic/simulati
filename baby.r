library(bench)
library(fst)
library(data.table)
library(feather)

nr_of_rows <- 1e6
set.seed(211)
# THIS IS THE DATA!!
df <- data.frame(Logical = sample(c(TRUE, FALSE, NA), prob = c(0.85, 0.1, 0.05), nr_of_rows, replace = TRUE), Integer = sample(1L:100L, nr_of_rows, replace = TRUE), Real = sample(sample(1:10000, 20) / 100, nr_of_rows, replace = TRUE), Factor = as.factor(sample(labels(UScitiesD), nr_of_rows, replace = TRUE)))

# Define read/write functions to time
csvfile <- function() {
  write.csv(df, "dataset.csv")
  read.csv("dataset.csv")
}

data.table_csv <- function() {
  fwrite(df, "dataset-data-table.csv")
  fread("dataset-data-table.csv")
}

saveRDA <- function() {
  save(list = "df", file = "dataset.rda")
  load("dataset.rda")
}

## saveRDATA <- function() { save(list = "df", file = "dataset.rdata"); load("dataset.rdata") }

baseRDS_nocompress <- function() {
  saveRDS(df, "dataset-nocompress.Rds", compress = FALSE)
  readRDS("dataset-nocompress.Rds")
}

baseRDS <- function() {
  saveRDS(df, "dataset.Rds")
  readRDS("dataset.Rds")
}

feather <- function(variables) {
  write_feather(df, "dataset.feather")
  as.data.frame(read_feather("dataset.feather"))
}

fst <- function() {
  write.fst(df, "dataset.fst")
  read.fst("dataset.fst")
}

# Run and benchmark results
results <- mark(csvfile(), data.table_csv(), saveRDA(), baseRDS_nocompress(),
  baseRDS(), feather(),
  fst(), iterations = 3,
  check = FALSE
)

# summarize
summary(results)
summary(results, relative = TRUE)
