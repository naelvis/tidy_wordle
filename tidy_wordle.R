# Libraries
library(tidyverse)
library(magrittr)
library(vroom)

# Read in word list
words_raw <- vroom("./Dictionary/parole.csv", 
                delim = ";")

# Only keep five letters words (w/o special characters)
words_five <- words_raw %>% 
  filter(str_detect(A, "^[:alpha:]{5}$")) %>% 
  mutate(A = str_to_lower(A)) %>% 
  unique

# Separate words in five columns
words_sep <- words_five %>% 
  separate(col = A,
           into = c("one", "two", "three", "four", "five"),
           sep = c(1, 2, 3, 4, 5))

# Source wordle functions
source("./Functions/wordle_functions.R")

# Trial run

# Round 1

best_words() %>% 
  head(25)

# Round 2

hint(word = "sales",
     color_string = "gyggg") %>% 
  best_words %>% 
  head(5)

# Round 3

hint(word = "sales",
     color_string = "gyggg") %>% 
  hint(word = "drama",
       color_string = "gvvgg") %>% 
  best_words %>% 
  head(5)

# Round 4

hint(word = "sales",
     color_string = "gyggg") %>% 
  hint(word = "drama",
       color_string = "gvvgg") %>% 
  hint(word = "brant",
       color_string = "gvvyy") %>%
  best_words %>% 
  head(5)
 