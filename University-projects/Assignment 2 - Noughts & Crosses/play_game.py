'''The main program for the Noughts and Crosses game.
This should only be ran if you have noughtsandcrosses.py file in the same directory.
'''

# Import the module required to delete the debug file
import os

# Import the module required for the game
import noughtsandcrosses

# Import the module required to clear the console
import clear_console

# Remove the debug file if it exists to prevent any bugs or errors
try:
    os.remove("debug")
    os.remove("ai_level")

except FileNotFoundError:

    # Do nothing if the file does not exist, this is to prevent errors from appearing
    pass

def main():
    """The main function for the Noughts and Crosses game.
    """

    # Create the values for the board using a list
    board = [ ['1','2','3'],\
              ['4','5','6'],\
              ['7','8','9']]

    # Display the welcome message from noughtsandcrosses.py's welcome() function
    noughtsandcrosses.welcome(board)

    # Set the total score to 0.
    # This is only ran once at the start when the game is started
    total_score = 0

    # Create a while loop to keep the game running.
    # This will only stop when the user quits the game using the menu's "q" option
    while True:

        # Display the menu from noughtsandcrosses.py's menu() function
        choice = noughtsandcrosses.menu()

        while choice not in ['1','2','3','4','q','debug']:
            print("Please enter a valid option")
            choice = noughtsandcrosses.menu()

        # This choice will play the game
        if choice == '1':

            # Clear the console for a clean game
            # clear_console.clear()

            # Initialise the game by loading the board
            score = noughtsandcrosses.play_game(board)

            # Add the score from the previous game to the total score
            total_score += score
            print('Your current score is:',total_score)

            # Removes ai_level so that it will reset the ai level
            # and prompt the player to choose a level the next game start
            os.remove("ai_level")

            print("Press enter to continue")
            print("")

        # This choice will save the score
        if choice == '2':

            # Save the score to the leaderboard
            noughtsandcrosses.save_score(total_score)

        # This choice will display the leaderboard
        if choice == '3':

            # Load the leaderboard and load the data in leaders
            leaders = noughtsandcrosses.load_scores()

            # Pass the leaders data to the display_leaderboard() function
            noughtsandcrosses.display_leaderboard(leaders)

        if choice == '4':
            noughtsandcrosses.rules()

        # This choice will quit the game
        if choice == 'q':

            print("")
            print('Thank you for playing Noughts and Crosses by Callum Wellard (########)')
            print('Good bye')

            # Delete the debug file if it exists to prevent unnessary files
            # from being on the user's computer
            os.remove("debug")

            # Break the while loop to stop the game
            break

        if choice == 'debug':
            # This will enable the debug mode
            # The argument is True as the argument asks if the
            # function is being called from the menu or not
            noughtsandcrosses.debug_mode(True)


# Program execution begins here
if __name__ == '__main__':
    clear_console.clear()
    main()
