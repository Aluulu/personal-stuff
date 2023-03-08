'''Allows the user to play a game of noughts and crosses against the computer
'''

# Import the module that provides the RNG for the computer's move
import random

# Import the module required to import the scores from the leaderboard
import json

# Import the module required to clear the console
import clear_console

def draw_board(board):
    """Prints the current board with formatting

    Args:
        board (List): The board to be printed
    """

    # The board is printed using dashes and pipes to create a grid
    print("-"*13)
    print("|", board[0][0],"|", board[0][1],"|", board[0][2],"|")
    print("-"*13)
    print("|", board[1][0],"|", board[1][1],"|", board[1][2],"|")
    print("-"*13)
    print("|", board[2][0],"|", board[2][1],"|", board[2][2],"|")
    print("-"*13)

def welcome(board):
    """Prints the welcome message

    Args:
        board (List): The list of the board to be passed to draw_board
    """

    print("Welcome to the Naughts and Crosses game developed by Callum Wellard (2228722)")
    print("This games uses a 3x3 board denoted by the numbers 1-9")
    print("The player will be denoted by an X and the computer will be denoted by an O")
    print("The board is as follows:")
    draw_board(board)


def initialise_board(board):
    """Initialises the board to be empty

    Args:
        board (List): The board that will be cleared

    Returns:
        list: Returns the newly cleared board
    """

    board[0][0] = " "
    board[0][1] = " "
    board[0][2] = " "
    board[1][0] = " "
    board[1][1] = " "
    board[1][2] = " "
    board[2][0] = " "
    board[2][1] = " "
    board[2][2] = " "

    return board

def get_player_move(board):
    """Gets the player move, checks if it is valid, and if it is, it will place an X in the cell

    Args:
        board (List): The board that the player will be placing their X in

    Returns:
        row (Int): The row of the cell that the player has chosen
        col (Int): The column of the cell that the player has chosen
    """

    # Ask the user for the square to put the X in
    print("Please enter the cell number to place your X in")
    number = input("")

    # Check if number is actually an integer using a while loop and isdigit()
    while not number.isdigit():
        print("Please enter a valid NUMBER between 1 and 9")
        number = input("")

    # Check if the number is a valid number using a while loop
    # by checking if it is between lower than 1 and greater than 9
    while int(number) < 1 or int(number) > 9:
        print("Please enter a valid number between 1 and 9")
        number = int(input(""))


    # A switch statement to determine the row and column of the square
    switch_statement = {
        "1": [0,0],
        "2": [0,1],
        "3": [0,2],
        "4": [1,0],
        "5": [1,1],
        "6": [1,2],
        "7": [2,0],
        "8": [2,1],
        "9": [2,2]
    }

    # Get the row and column from the switch statement
    row = switch_statement.get(number)[0]
    col = switch_statement.get(number)[1]

    # Check if the cell is empty by checking if it is a space
    while board[row][col] != " ":
        print("That space is occupied already, please choose another space.")
        number = input("")
        row = switch_statement.get(number)[0]
        col = switch_statement.get(number)[1]

    return row, col

def choose_computer_move(board):
    """Generates the computers move

    Args:
        board (List): The board that the computer will be placing their O in

    Returns:
        row (Int): The row of the cell that the computer has chosen
        col (Int): The column of the cell that the computer has chosen
    """

    ai_level = computer_ai_level()

    # If the AI level is 0, the computer will choose a random cell
    if ai_level == 0:

        # Run the function that handles level 0's AI
        row, col = calculate_ai_level_0_move(board)

        # Return the row and column of the cell that the computer has chosen
        return row, col

    # This Ai will weigh the cells on the board to determine the most optimal moves
    if ai_level == 1:

        # Run the function that handles level 1's AI
        row, col = calculate_ai_level_1_move(board)

        # Return the row and column of the cell that the computer has chosen
        return row, col

    if ai_level == 2:

        # Run the function that handles level 2's AI
        row, col = calculate_ai_level_2_move(board)

        # Return the row and column of the cell that the computer has chosen
        return row, col

    return None, None


def check_for_win(board, mark):
    """Checks if there is a win by checking diagonally, horizontally and vertically

    Args:
        board (List): The board that will be checked for a win
        mark (String): The current mark (Player) that will be checked for a win

    Returns:
        True (Boolean): Returns True if there is a win
        False (Boolean): Returns False if there is no win
    """

    # Iterate through the board and check if there is a row win condition
    # For each row in the board
    for row in board:

        # Check rows 0, 1, and 2; check if they all have the same mark
        if row[0] == mark and row[1] == mark and row[2] == mark:

            # If they do, return True
            return True

    # Iterate through the board and check if there is a column win condition
    for col in range(3):

        # This will go through each row and check if the column contains a mark
        # It does this by iterating through 0, 1, and 2 using the 'in range' for each row
        if board[0][col] == mark and board[1][col] == mark and board[2][col] == mark:

            # If they do, return True
            return True

    # A simple if statement to check if there is a diagonal win condition
    if board[0][0] == mark and board[1][1] == mark and board[2][2] == mark:

        # If there is a top left to bottom right diagonal win, return True
        return True

    if board[0][2] == mark and board[1][1] == mark and board[2][0] == mark:

        # if there is a top right to bottom left diagonal win, return True
        return True

    # If there is a win, return True, otherwise return False

    return False

def check_for_draw(board):
    """Checks the board state for a draw

    Args:
        board (List): The board that will be checked for a draw

    Returns:
        True (Boolean): Returns True if the board has reached a draw
        False (Boolean): Returns False if the board has not reached a draw
    """

    # Iterate through the board and check if there is a space
    # For each row in the board
    for row in board:

        # Check every cell in said row
        for cell in row:

            # Check if the cell is a space
            if cell == " ":

                # If there is a space, the board must not be full, so return False
                return False

    # If there is no space, then it is a draw, so return True
    return True

def play_game(board):
    """Loops through the game until a win or draw is achieved

    First it clears the board by calling initialise_board(board)
    Then it displays the board to the player by calling display_board(board)
    Then it goes through an infinite loop doing the following:

    Runs through the players turn by calling get_player_move(board)
    Sets the players mark as the current mark
    It then places the player's mark on the board
    Afterwards it checks if the player has won, and then if the game is drawn
    Once it has finished, it redraws the board with current marks

    Now it runs through the computers turn by calling choose_computer_move(board)
    Then it sets the computer's mark as the current mark
    It then places the computer's mark on the board
    Afterwards it checks if the computer has won, and then if the game is drawn
    Once that has finished, it redraws the board with current marks

    If the game is won or drawn, it will break out of the loop

    Args:
        board (List): The board that will be used to play the game

    Returns:
        +1 (Int): Returns if the player wins
        0 (Int): Returns if the game is drawn
        -1 (Int): Returns if the computer wins
    """

    # Clear the console
    clear_console.clear()

    # Clear the board so that the values are all spaces
    # This will make an empty board
    initialise_board(board)

    # Ask the user what level of AI they want to play against
    ai_level = computer_ai_level()
    print("You have selected AI level", ai_level)

    # Draw the board so that the player can see an empty board
    draw_board(board)

    # Start the game loop until a win or draw is achieved
    # This will run until a break is called in check_for_win or check_for_draw
    while True:

        # Get the player's move and return the row and col that they have chosen
        # This will be used to place the player's mark on the board
        row, col = get_player_move(board)

        # Set mark as "X" so that it can be placed on the board, and check for a win
        mark = "X"

        # Set the cell to an X based on the row and col from get_player_move(board)
        board[row][col] = mark

        # Check if the player has won
        if check_for_win(board, mark) is True:

            clear_console.clear()
            draw_board(board)
            print("The player has won!")

            # Sets the score to 1 to indicate a win
            # This is used at the end of the function
            score = 1
            break

        # Check if the game is a draw
        if check_for_draw(board) is True:

            clear_console.clear()
            draw_board(board)
            print("The game is a draw!")

            # Sets the score to 0 to indicate a draw
            # This is used at the end of the function
            score = 0

            break

        # Clear the console so that the board is not displayed twice
        clear_console.clear()

        # Run through the computer's move
        row, col = choose_computer_move(board)

        # Because Pylint will complain if I there is not return values for choose_computer_move()
        # I have added a check to see if row returns None. If it does then a error has occurred
        # as the function should always return a value and never reach None
        if row is None:
            print("The Ai has encountered an error, the game will result as a draw")
            print("Press Enter to continue")
            input("")
            return 0

        # Set mark as "0" to check for a win
        mark = "O"

        # Set the cell to an O
        board[row][col] = mark

        # Draw the board
        draw_board(board)

        # Check if the player has won
        if check_for_win(board, mark) is True:

            clear_console.clear()
            draw_board(board)
            print("The computer has won!")

            # Sets the score to -1 to indicate a loss
            # This is used at the end of the function
            score = -1
            break

        # Check if the game is a draw
        if check_for_draw(board) is True:

            clear_console.clear()
            draw_board(board)
            print("The game is a draw!")

            # Sets the score to 0 to indicate a draw
            # This is used at the end of the function
            score = 0
            break

    # If the score is 1, then the player has won
    # It will add this score as the return value, which will be used to update the leaderboard
    if score == 1:
        return +1

    # If the score is 0, then the game is a draw
    # It will add this score as the return value, which will be used to update the leaderboard
    if score == 0:
        return 0

    # If the score is -1, then the computer has won
    # It will add this score as the return value, which will be used to update the leaderboard
    return -1



def menu():
    """Displays the menu and asks the user to select an option

    Returns:
        Choice (String): Returns the user's choice
    """

    # Check if debug mode is enabled. Used for displaying in the menu
    if debug_mode(False):
        current_debug_status = "Enabled"
    else:
        current_debug_status = "Disabled"

    # Display the menu to the player
    print("Please select one of the following options:")
    print("1 - Play the game")
    print("2 - Save score in file 'leaderboard.txt'")
    print("3 - Load and display the scores from the 'leaderboard.txt'")
    print("4 - Display the rules of the game")
    print("q - End the program")
    print("debug - Enables debug mode (Currently: " + str(current_debug_status) + ")")

    # Ask the player to select an option
    choice = str(input("Your choice: "))
    return choice

def load_scores():
    """Loads the scores from the leaderboard.txt file

    Returns:
        leaders (Dict): The dictionary containing the scores from leaderboard.txt file
    """

    # Open the file with read privileges
    try:
        with open("leaderboard.txt", "r", encoding="utf-8") as input_file:

            # Take the contents of the file and put it into a variable
            file_contents = input_file.read()

            print("The file contents are: ")
            print(file_contents)

        # Convert the contents of the file from a string into a dictionary using json
        leaders = json.loads(file_contents)
        print("The type of leaders is: ", type(leaders))

    # If the file does not exist, then a IOError will be thrown
    # Now it will print an error message
    except IOError:
        print("leaderboard.txt does not exist")

        # Set leaders as zero so that it can be returned
        leaders = 0

    return leaders

def save_score(score):
    """Saves the score to the leaderboard.txt file

    Args:
        score (Int): The score the player has achieved
    """

    # Ask the player for their name so that it can be saved to the leaderboard
    print("Please enter your name:")
    name = str(input(""))

    # Load the scores from the leaderboard.txt file
    # Note that leaders becomes a dictionary
    leaders = load_scores()

    # Append the new score to the dictionary
    leaders[name] = score

    # Open the file with write privileges
    # Note that writing to a file that does not exist will create it
    try:
        with open("leaderboard.txt", "w", encoding="utf-8") as input_file:

        # Convert the dictionary into a string using json
        # Then write the string to the file
        # Since we loaded the file as a dictionary, we can just write it back to the file...
        # without having to worry about where the data is coming from
            input_file.write(json.dumps(leaders))

    except IOError:
        print("leaderboard.txt could not be created or opened by the program")
        print("Check that you have the correct permissions in the file location")


def display_leaderboard(leaders):
    """Displays the leaderboard scores fom highest to lowest

    Args:
        leaders (Dict): The dictionary containing the leaderboard scores
    """

    # develop code to display the leaderboard scores
    # passed in the Python dictionary parameter leader

    # Sort the dictionary by the values so that the highest score is at the top
    # This also converts the dictionary into a list
    leaders = sorted(leaders.items(), key=lambda x: x[1], reverse=True)

    # Clears the screen to make the leadboard easier to read
    clear_console.clear()

    # Print each name and score from leaders on each separate line
    for name, score in leaders:
        print(name, score)

    # Let the user exit when they are ready
    print("Press Enter to continue...")
    input("")

def debug_mode(run_from_menu):
    """Check and switch debug mode

    Args:
        run_from_menu (Boolean): True if the function is being run from the menu, False otherwise

    Returns:
        True (Boolean): Returns True if debug mode is on
        False (Boolean): Returns False if debug mode is off
    """

    # Define the current mode as false
    current_mode = 0

    # Open the file with read privileges to check the current mode
    try:
        with open("debug", "r", encoding="utf-8") as input_file:
            current_mode = input_file.read()

    # If there isn't a file, then clearly debug mode hasn't been started before
    # Create the file and populate it with 'False'
    except IOError:

        # Open the file with write privileges to change the mode to false
        with open("debug", "w", encoding="utf-8") as input_file:
            input_file.write("False")

        # Reopen the file with read privileges to check the current mode
        with open("debug", "r", encoding="utf-8") as input_file:
            current_mode = input_file.read()

    if current_mode == 'True':
        current_mode = True
    if current_mode == 'False':
        current_mode = False

    if run_from_menu is True:

        # Clear the console to make it easier to read from the menu
        clear_console.clear()

        # if the current mode is 'false', then it will be switched to true
        if current_mode is False:

            # Set the global variable to True
            current_mode = True

            try:

                # Open the file with write privileges to change the mode to true
                with open("debug", "w", encoding="utf-8") as input_file:
                    input_file.write("True")

            except IOError:
                print("Unable to write to debug file. Please check file and folder permissions")

            # Debug Mode is now on

            # Clear the console to make it easier to read
            clear_console.clear()

        # Else if the current mode is true, then it will be switched to false
        else:
            current_mode = False

            try:

                # Open the file with write privileges to change the mode to False
                with open("debug", "w", encoding="utf-8") as input_file:
                    input_file.write("False")

            except IOError:
                print("Unable to write to debug file. Please check file and folder permissions")

            # Debug Mode is now off

            # Clear the console to make it easier to read
            clear_console.clear()


    # Check the current mode. If it's true then return True
    if current_mode is True:
        return True

    # If the current mode is false, then return False
    return False

def rules():
    """Displays the rules of the game
    """

    clear_console.clear()
    print("The rules of the game are:")
    print("1. The game is played on a grid that's 3 squares by 3 squares.")
    print("")

    print("2. You are X, your friend (or the computer in this case) is O.")
    print("Players take turns putting their marks in empty squares.")
    print("")

    print("3. The first player to get 3 of her marks in a row")
    print("(up, down, across, or diagonally) is the winner.")
    print("")

    print("4. When all 9 squares are full, the game is over.")
    print("If no player has 3 marks in a row, the game ends in a tie.")
    print("")

    print("Press Enter to continue...")
    input("")
    clear_console.clear()

def computer_ai_level():
    """Ask the user what level they want the computer to play at

    Returns:
        0 (Int): Computer will make a random move (No logic)
        1 (Int): Computer will use weighted locations to make a move
        2 (Int): Computer will use minimax algorithm to make a move
    """

    try:

        # Open the file with read privileges to check the Ai's level
        with open("ai_level", "r", encoding="utf-8") as input_file:
            current_ai_level = input_file.read()

    # If the file doesn't exist, then the user hasn't chosen a level yet
    except IOError:

        # Ask the user what level they want the computer to play at
        print("What level do you want the computer to play at?")
        print("0 - Easy")
        print("1 - Medium")
        print("2 - Hard")
        computer_level = input("")

        # Check if the user has entered a valid input
        while computer_level not in {'0', '1', '2'}:
            print("Invalid input. Please try again")
            computer_level = input("")

        # Clear the console to make it easier to read what AI level the user has chosen
        clear_console.clear()

        # Open the file with write privileges to change the mode to false
        with open("ai_level", "w", encoding="utf-8") as input_file:

            input_file.write(str(computer_level))

        # Reopen the file with read privileges to check the current ai level
        with open("ai_level", "r", encoding="utf-8") as input_file:
            current_ai_level = input_file.read()

    if current_ai_level == '0':
        if debug_mode(False) is True:
            print("DEBUG: The computer is playing with random moves")
        return 0

    if current_ai_level == '1':
        if debug_mode(False) is True:
            print("DEBUG: The computer is playing with weighted locations")
        return 1

    if current_ai_level == '2':
        if debug_mode(False) is True:
            print("DEBUG: The computer is playing at hard level")
        return 2

    # If for some reason the file has been corrupted or otherwise, then return 0
    return 0

def calculate_ai_level_0_move(board):
    """Picks a random move for the computer to make

    Args:
        board (List): The current state of the board

    Returns:
        row (Int): The row the computer has chosen
        col (Int): The column the computer has chosen
    """

    # Get the row and column from the using random number generator
    row = random.randint(0,2)
    col = random.randint(0,2)

    # Check if the cell is empty by checking if it is a space
    while board[row][col] != " ":

        # Debugging code to check if the computer is choosing an occupied space
        if debug_mode(False):
            print("Debug: Computer chose an occupied space, choosing another space.")
            print("Debug: Computer tried to choose row:", row, "and column:", col)
            print("")

        # Try a random row and column again
        row = random.randint(0,2)
        col = random.randint(0,2)

    return row, col


def calculate_ai_level_1_move(board):
    """Picks a move for the computer to make based on weighted locations

    Args:
        board (List): The current state of the board

    Returns:
        row (Int): The row the computer has chosen
        col (Int): The column the computer has chosen
    """

    # The middle cell is the best move as it is the centre of
    # the board, giving it access to 5 win conditions. It will always be chosen if it is free

    # The corners are the second best move as they are the furthest
    # away from the middle cell, giving it access to 3 win conditions

    # The side cells are the worst move as they are the closest to
    # the middle cell, giving it access to 2 win conditions

    # The cells are weighed in the following order: middle, corners, side cells
    # The cells are weighted in the following order: 5, 3, 2

    corner_options = 0
    side_options = 0
    free_corners = []
    free_sides = []

    # Iterate through the board and weigh the cells

    # Iterate row the three rows
    for row in range(3):

        # Iterate through the three columns
        for col in range(3):

            # If the current selected row and column is contains an empty space
            if board[row][col] == " ":

                # If the row and column is the middle cell, return it
                if row == 1 and col == 1:

                    if debug_mode(False):
                        print("DEBUG: Middle cell is free, choosing it")
                        print("")

                    # Return the middle cell as row and col                    
                    return row, col

                # If it is not the middle cell, check the four corners
                if (row == 0 and col == 0) or (row == 0 and col == 2) \
                    or (row == 2 and col == 0) or (row == 2 and col == 2):

                    # If the cell is a corner and empty, add it to the list of free corners
                    corner_options += 1
                    free_corners.append([row, col])

                # Else check the four side cells and add them to the list of free side cells
                else:
                    side_options += 1
                    free_sides.append([row, col])

    if debug_mode(False):
        print("Debug: There are", corner_options, "free corners")
        print("Debug: There are", side_options, "free sides")
        print("Debug: Free corners:", free_corners)
        print("Debug: Free sides:", free_sides)
        print("")

    # Check if there are free corners
    if corner_options > 0:
        # Choose a random corner
        random_corner = random.randint(0, len(free_corners) - 1)
        row = free_corners[random_corner][0]
        col = free_corners[random_corner][1]
        return row, col

    # Check if there are free side cells
    if side_options > 0:
        # Choose a random side cell
        random_side = random.randint(0, len(free_sides) - 1)
        row = free_sides[random_side][0]
        col = free_sides[random_side][1]
        return row, col

    # If there are no free cells, return None, None
    return None, None

def calculate_ai_level_2_move(board):
    """_summary_

    Args:
        board (_type_): _description_

    Returns:
        _type_: _description_
    """

    if debug_mode(False):
        print("DEBUG: Checking if the Ai can win this turn")

    # Check if the computer can win in the next move. (This is the first move always)
    # Iterate through the three rows
    for row in range(3):

        # Iterate through the three columns
        for col in range(3):

            # Check if the current position on the board is empty
            if board[row][col] == " ":

                # If the current position is empty, place an 'O' mark there
                board[row][col] = "O"

                # Now check for a win using the check_for_win function
                if check_for_win(board, "O"):

                    if debug_mode(False):
                        print("DEBUG: Found Player win block in row:", row, "and column:", col)

                    # If a win is found, return the row and column
                    return row, col

                # If no win is found, remove the 'O' mark from the board and go check the next cell
                board[row][col] = " "

    if debug_mode(False):
        print("DEBUG: Unable to Win. Checking if the Player can win this turn")

    # Check if the Player can win in the next move to block them.
    # It is done this way so it will always play the winning move, even if
    # it found it can block the player's winning move first
    # Iterate through the three rows
    for row in range(3):

        # Iterate through the three columns
        for col in range(3):

            # Check if the current position on the board is empty
            if board[row][col] == " ":

                # If the current position is empty, place an 'X' mark there
                board[row][col] = "X"

                # Now check for a win using the check_for_win function
                if check_for_win(board, "X"):

                    if debug_mode(False):
                        print("DEBUG: Found Player win block in row:", row, "and column:", col)

                    # If a win is found, return the row and column
                    return row, col

                # If no win is found, remove the 'O' mark from the board and go check the next cell
                board[row][col] = " "


    if debug_mode(False):
        print("DEBUG: No win found, calculating best move based on weighted locations")

    # Check the best move based on the minimax algorithm

    row, col = calculate_ai_level_1_move(board)

    return row, col
