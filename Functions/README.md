# tidy_wordle/Functions

The script contains nine functions:

* *green_letter*, *gray_letter* and *yellow_letter* all take in input a list of words and filter it assuming a colored letter is given. For example, if we know that we have a green **a** in the fourth position, we want to keep words such as sal**a**d and discard words such as pizza[^1].

  If we have a yellow **a** in second position, we will want to discard all words containing **a** in the second position as well as words without **a** in the first, third, fourth or fifth position. Furthermore, if a green **a** is already given somewhere (say in fourth position), then we should ignore it, thus discarding words without **a** in the first, third or fifth position.

  Lastly, if we have a gray **a** in third position we need to discard all words containing **a**. But if we already have **a**s in yellow somewhere, we are only allowed to discard words with a number of **a**s greather than the number of yellow **a**s. Green **a**s and positions should be taken out of the equation from the very beginning.

  I could not really catch all of the special constellation for letters appearing both in gray and in yellow without completely destroying the symmetry between the three functions, so at the current stage if a letter appears both in yellow and gray the *gray_letter* function does not activate and the hint is hanlded by the *count_letter* function instead (see below);

* *hint_letter* is just a switch that activates the desired function from the ones above. So it also requires a color as additional input;

* *count_letter* takes care of cases in which a letter is hinted more than once in different colors. We want to include the deduction that if a letter appears both in yellow/green and gray, then we know that that letters appears exactly as many times in the word as the number of yellow/green hints.
  The main difference between this function and the *hint_letter* bundle is that the function works on the whole word instead than on a letter-by-letter basis.

* *determine_yellow* and *determine_green* are two helper functions for the *hint* function which is coming next. They respectively determine which letters appear in both yellow and gray and which positions are green.

* *hint* is the function that we actually end up using. It takes in input a list of words - which can be the initial list or a list already filtered from the steps before - and returns a list of words filtered according to the new hint.

  The new hint is coded as the five-letter word we provided and the response from Wordle. This is a five letter string, each letter corresponding to the color of the given cell:

  * *g* stands for *gray*;
  * *y* stands for *yellow*;
  * *v* stands for *green*.

  So for the following hint

  ![](https://raw.githubusercontent.com/naelvis/tidy_wordle/main/Other/DREAM.png)

  We would input "gvgyg".

  The function processes the dictionary through the five hints given via *hint_letter* and then calls *count_letter* to take into account margin cases.

* *best_words* sorts a given list of words to provide the next input. It does not return just a single word, but rather the whole sorted list, because the input dictionary seems to be substantially larger than the one Wordle uses. I never had to go further than the fifth element in the sorted list.

  For the sorting, the function looks into how often each letter is found in each of the positions, and ranks every word accordingly. The logic is best explained with an example. The word **dream** has a rank of 1801, which is computed as the sum of each letter's rank:

  ![Screenshot of an equation because we cannot have nice things](https://raw.githubusercontent.com/naelvis/tidy_wordle/main/Other/DREAM_rank.png)

  The letter **d** appears in first position 348 times in the whole dictionary, the letter **r** appears in second position 520 times, etc.

  There is actually one case when *best_words* returns a single word - this is when after the various filters only one word remains.

So we start by using *best_words* on the whole dictionary - the suggested word is **sales** -, then pipe the various hints with *hint* to filter the dictionary to be sorted. See the README and the script in the main directory for an example.

[^1]: This is coincidentally one of the few occasions when one would discard pizza in favor of salad.
