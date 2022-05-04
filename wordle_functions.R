# Functions

gray_letter <- function(data, position, letter, green_positions = NULL) {
  
  if (is_empty(green_positions)) {
    filter(data,
           !if_any(everything(), ~ .x == letter)) %>% 
      return
  } else {
    filter(data,
           !if_any(!green_positions, ~ .x == letter)) %>% 
      return
  }
  
}

green_letter <- function(data, position, letter) {
  
  filter(data,
         .data[[position]] == letter) %>% 
    return
  
}

yellow_letter <- function(data, position, letter, green_positions = NULL) {
  
  if (is_empty(green_positions)) {
    filter(data,
           .data[[position]] != letter) %>% 
      filter(if_any(!position, ~ {.x == letter})) %>% 
      return
  } else {
    filter(data,
           .data[[position]] != letter) %>% 
      filter(if_any(!position, ~ .x == letter)) %>% 
      filter(if_any(!green_positions, ~ .x == letter)) %>% 
      return
  }
  
}

hint_letter <- function(data, color, position, letter, green_positions = NULL) {
  
  switch(color,
         gray = gray_letter(data, position, letter, green_positions),
         green = green_letter(data, position, letter),
         yellow = yellow_letter(data, position, letter, green_positions))
  
}

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
  
  data %>% 
    hint_letter(color = colors[[1]], letter = letters[[1]], green_positions = green_positions, 
                position = "one") %>% 
    hint_letter(color = colors[[2]], letter = letters[[2]], green_positions = green_positions, 
                position = "two") %>%
    hint_letter(color = colors[[3]], letter = letters[[3]], green_positions = green_positions, 
                position = "three") %>%
    hint_letter(color = colors[[4]], letter = letters[[4]], green_positions = green_positions, 
                position = "four") %>%
    hint_letter(color = colors[[5]], letter = letters[[5]], green_positions = green_positions, 
                position = "five") %>% 
    return
  
}

best_words <- function(selected_words = words_sep) {
  
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
    unite(col = "Word", sep = "", remove = TRUE) %>% 
    cbind(words_ranked) %>% 
    arrange(desc(total))
  
  if(nrow(words_final) == 1) {
    paste("I think the wordle is",
          words_final[[1]][[1]]) 
  } else {
    return(words_final)
  }
  
}