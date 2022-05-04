# tidy_wordle/Dictionary

The dictionary comes from the [SCOWL database](http://wordlist.aspell.net). If you want to generate it just download the .zip file and run from the terminal:

```bash
./mk-list american 60 > parole.csv
```

The "60" version seems more than sufficient for the program - some of the words are already not in the wordle list. See the README in the .zip file for details on the different versions of the dictionary.

The actual reason for this README is that I obtained this error message when I first tried to run the script above:

```bash
/usr/bin/perl^M: bad interpreter: No such file or directory
```

The problem has to do with line endings and I won't pretend I really understood the underlying issue, but it can be fixed with this command:

```bash
perl -i -pe 'y|\r||d' mk-list 
```

