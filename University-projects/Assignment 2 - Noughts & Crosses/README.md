# Important

This project had some limitations and I did the best I could with what I had.
Some of the limitations included:
- Not being able to change variable names and return values
- Not being able to remove functions
- Make the PyLint score as high as possible (This was a pain with public variables)
- I wasn't sure if I was able to use any other imports other than the ones provided in the template. I uploaded two versions for my assignment. This copy includes the import of **clear_console.py**

The specification didn't say whether I could add functions or not so I did it.

There were a few more limitations but I'm uploading this weeks after it was due.

## How to run

Make sure **play_game.py** and **noughtsandcrosses.py** are in the same folder

Run **play_game.py**

## Known Bugs

### Debug file

Clicking the debug menu creates a file called "debug" in the directory where the game is stored. It should delete it once the game exits but if the game is closed without exiting (such as a crash) then the file is not deleted.

### Leaderboard bugs

Trying to load the leaderboard without "leaderboard.txt" in the same directory will crash the game.
I have left this bug in here instead of fixing it as this was how it was sent off to get marked.

The same happens with saving. Make sure to keep "leaderboard.txt" in the same directory as the game.

If I could change this, I would change it so that when the error is caught, it handles it instead of continuing on like it currently does.