# Functions

# Filter words based on color and position of a letter

green_letter <- function(data, position, letter) {
  
  filter(data,
         .data[[position]] == letter) %>% 
    return
  
}

gray_letter <- function(data, position, letter,
                        green_positions,
                        yellow_positions) {
  
  if (yellow_positions) {
    filter(data,
           .data[[position]] != letter) %>% 
      return
  } else {
    filter(data,
           if_all(!any_of(green_positions), ~ .x != letter)) %>% 
      return
  }
  
}

yellow_letter <- function(data, position, letter) {
  
  filter(data,
         .data[[position]] != letter) %>% 
    filter(if_any(!all_of(position), ~ {.x == letter})) %>% 
    return
  
}

# Bundle the three functions above

hint_letter <- function(data, color, position, letter, 
                        green_positions, yellow_positions) {
  
  switch(color,
         gray = gray_letter(data, position, letter, 
                            green_positions, yellow_positions),
         green = green_letter(data, position, letter),
         yellow = yellow_letter(data, position, letter))
  
}

# Checks the number of allowed letters in a word

count_letter <- function(data, word, color_string) {
  
  word_color <- cbind(str_split(word, "") %>% 
                        as.data.frame %>% 
                        setNames("word"), 
                      str_split(color_string, "") %>% 
                        as.data.frame %>% 
                        setNames("color")) %>% 
    mutate(value = str_replace(color, "v|y", "1"),
           value = str_replace(value, "g", "0"),
           value = as.numeric(value)) %>% 
    group_by(word) %>% 
    summarise(color = paste0(color, collapse = ""),
              value = sum(value)) %>% 
    filter(str_detect(color, "g"),
           value > 0) 
  
  if (nrow(word_color)) {
    map2(word_color$word, word_color$value,
         function(letter, number) {
           data %>% 
             unite(col = "Word", sep = "", remove = FALSE) %>% 
             mutate(count = str_count(Word, pattern = letter)) %>% 
             filter(count <= number) %>% 
             select(-count)
         }) %>% 
      reduce(inner_join, by = c("one", "two", "three", "four", "five", 
                                "Word")) %>% 
      select(-Word) %>% 
      return 
  } else {
    return(data)
  }
}

# Helper functions to determine green and yellow positions in a word

determine_green <- function(colors) {
  
  green_positions <- imap(colors,
                          ~ {ifelse(.x == "green",
                                    .y,
                                    NA)}) %>% 
    discard(is.na) 
  
  if (is_empty(green_positions)) {
    green_positions <- NULL
  } else {
    green_positions %<>% 
      map(~ {switch(.x,
                    "1" = "one",
                    "2" = "two",
                    "3" = "three",
                    "4" = "four",
                    "5" = "five")}) %>% 
      reduce(c)
  }
  
}

determine_yellow <- function(letters, colors) {
  
  cbind(letters %>% 
          array %>% 
          as.data.frame %>% 
          setNames("word"), 
        colors %>% 
          array %>% 
          as.data.frame %>% 
          setNames("color")) %>% 
    mutate(value = str_replace(color, "yellow", "1"),
           value = str_replace(value, "gray|green", "0"),
           value = as.numeric(value)) %>% 
    group_by(word) %>% 
    summarise(color = paste0(color, collapse = ""),
              value = sum(value)) %>% 
    filter(str_detect(color, "gray"),
           value > 0) %>% 
    transmute(word = word,
              value = TRUE) %>% 
    {full_join(letters %>% 
                 array %>% 
                 as.data.frame %>% 
                 setNames("word"),
               .,
               by = "word")} %>% 
    mutate(value = ifelse(is.na(value),
                          FALSE,
                          value)) %>% 
    use_series(value)
  
}

# Filter words based on a hint (a word and the colours returned)

hint <- function(data = words_sep,
                 word,
                 color_string) {
  
  letters <- map(1:5,
                 ~ str_sub(word, start = .x, end = .x))
  
  colors <- map(1:5,
                ~ str_sub(color_string, start = .x, end = .x)) %>% 
    map(~ switch(.x,
                 g = "gray",
                 v = "green",
                 y = "yellow"))
  
  positions <- c("one",
                 "two",
                 "three",
                 "four",
                 "five")
  
  green_positions <- determine_green(colors)
  yellow_positions <- determine_yellow(letters, colors)
  
  map(1:5,
      ~ {data %>%
          hint_letter(color = colors[[.x]], 
                      letter = letters[[.x]], 
                      green_positions = green_positions,
                      yellow_positions= yellow_positions[[.x]],
                      position = positions[[.x]])}) %>% 
    reduce(inner_join, by = positions) %>%
    count_letter(word = word, color_string = color_string) %>% 
    return
  
}

# Given a list of words sort them from most to least common

best_words <- function(selected_words = words_sep, n = 5) {
  
  # Ranking for each letter/position according to frequency
  
  words_ranking <- selected_words %>% 
    names() %>% 
    map_dfr(~ count(selected_words, .data[[.x]])) %>% 
    pivot_longer(cols = c("one", "two", "three", "four", "five"),
                 names_to = "position",
                 values_to = "letter") %>% 
    filter(!is.na(letter)) %>% 
    pivot_wider(names_from = position, values_from = n)
  
  # Compute rank for each word
  
  words_ranked <- selected_words %>%
    names() %>% 
    map(~ {
      selected_words %>% 
        rename_with(.fn = ~ paste("letter"),
                    .cols = all_of(.x)) %>% 
        select(letter) %>% 
        left_join(select(words_ranking,
                         all_of(c(.x, "letter"))),
                  by = "letter")
    }) %>% 
    reduce(cbind) %>% 
    select(-letter) %>% 
    mutate(total = rowSums(across())) %>% 
    select(total)
  
  # Bind rank to original list
  
  words_final <- selected_words %>% 
    unite(col = "Word", sep = "") %>% 
    cbind(words_ranked) %>% 
    arrange(desc(total))
  
  if(nrow(words_final) == 1) {
    paste("I think the wordle is",
          words_final[[1]][[1]]) 
  } else {
    words_final %>% 
      select(-total) %>% 
      head(n) %>% 
      return
  }
  
}