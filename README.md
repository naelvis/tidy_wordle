# tidy_wordle

I wanted to have a small piece of code that tries to solve the daily wordle puzzle. This is a simple tidy implementation.

The script in page loads the dictionary I used, performs some minimal preprocessing and shows an example.

The idea is to add the hints provided by Wordle step by step in a pipe:

![](https://raw.githubusercontent.com/naelvis/tidy_wordle/main/Other/pipe.png)

Every call to *hint* filters the dictionary and pass it on to either the next *hint* call to filter it further or, finally, to *best_words* to provide a list of the most probable words satisfying the restrictions.

 For more details about the functions and the dictionary used please see the README in respectively the Functions and Dictionary repository.
