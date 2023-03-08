'''
Encrypt or decrypt a message provided into the console or a file using the Ceasar Cipher
'''
# Coursework Assessment 1
# Name: Callum Wellard
# Student No: XXXXXXX (Blanked for privacy)

# A Caesar Cipher Program

# This is used to check if a file exists using os.path.exists in is_file()
import os.path

def welcome():
    """Welcome the user, and describe what the program does

    Returns:
        No value is returned
    """
    print("Welcome to the Caesar Cipher")
    print("This program encrypts and decrypts text with the Caesar Cipher")


def enter_message():
    """Allows the user to input the mode, message, and shift number

    Returns:
        mode (string): Returns what mode the user wishes to use (encrypt/decrypt)
        message (string): Returns the message that the user wishes to encrypt/decrypt
        shift (int): Returns the shift number that is used when moving up or down the alphabet
    """

    # Check if the user wishes to use a message from the console or from a file
    mode, message, filename, shift = message_or_file()

    # If there is a filename, then the user must have specified to read from a file
    # So if there isn't a filename, then the user must have wanted to write from the console
    if filename is not None:
        message = process_file(filename)
    else:
        if mode == "e": # If the user wanted to encrypt, prompt for message
            print("What message would you like to encrypt?")
            message = str(input())
        else: # If the user wanted to decrypt, prompt for message
            print("What message would you like to decrypt?")
            message = str(input())

    # Ask the user for the shift number
    print("What is the shift number?")
    shift = input("")

    # Catch if shift is not a number
    while shift.isdigit() is False:
        print("Please input a NUMBER")
        shift = input("")

    return (str(mode), message, int(shift))


def encrypt(message, shift):
    """Encrypt the message using the Caesar Cipher, using a shift number.

    Args:
        message (list): The message to be encrypted. Inputted by user
        shift (int): The number in which the message will be shifted by. Inputted by user

    Returns:
        encrypted_message (string): The encrypted message after it has been shifted
    """
    # Declare alphabet as every letter in the alphabet
    # This is used as a way to check a letters index, and move the
    # letters in the variable message around
    alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    # Covert the message to uppercase
    message = [x.upper() for x in message]

    # Declare an empty variable for use in the loop
    encrypted_message = ""

    # Loop through each item in the list
    for items_in_list in message:

        # Loop through every character in the list's item to be encrypted
        for character in items_in_list:

            # Check if message has characters in alphabet
            if character in alphabet:

                # Get the position of the character in message
                index = alphabet.index(character)

                # Use modulus to prevent index from overflowing
                encrypted_message_index = (index + shift) % 26

                # The encrypted message is the message plus the new location of the letter index
                encrypted_message = encrypted_message + alphabet[encrypted_message_index]

            # If the message contains non-alphabet character, then do the following
            else:

                # Add to the encrypted message the non-alphabet character
                encrypted_message = encrypted_message + character

    # Returns the encrypted message to main()
    return encrypted_message


def decrypt(message, shift):
    """Decrypts the message using the Caesar Cipher, using a shift number.

    Args:
        message (list): The message to be decrypted. Inputted by user
        shift (int): The number in which the message will be shifted by. Inputted by user

    Returns:
        decrypted_message (string): The decrypted message after it has been shifted
    """

    # Declare alphabet as every letter in the alphabet
    # This is used as a way to check a letters index, and move the
    # letters in the variable message around
    alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    # Covert the message to uppercase
    message = [x.upper() for x in message]

    # Declare an empty variable for use in the loop
    decrypted_message = ""

    # Loop through each item in the list
    for items_in_list in message:

        # Loop through every character in the list's item to be encrypted
        for character in items_in_list:

            # Check if message has characters in alphabet
            if character in alphabet:

                # Get the position of the character in message
                index = alphabet.index(character)

                # Add 26 to prevent the numbers from ever going negative
                # Then, use modulus to prevent index from overflowing
                decrypted_message_index = (26 + index - shift) % 26

                # The decrypted message is the message plus the new location of the letter index
                decrypted_message = decrypted_message + alphabet[decrypted_message_index]

            # If the message contains non-alphabet character, then do the following
            else:

                # Add to the decrypted message the non-alphabet character
                decrypted_message = decrypted_message + character

    # Returns the decrypted message to main()
    return decrypted_message



def process_file(filename):
    """Process file and get contents. Store as list_messages

    Args:
        filename (string): The name of the file the user selected
        mode (string): The letter denoting what mode the user wishes to use
        shift (int): How many letters the program will shift the letters by

    Returns:
        list_messages (list): A list of words from the file the user selected
    """
    # Declare an empty list
    # This is used as files can contain multiple lines
    list_messages = []

    # Declare an empty string for use in a file
    # This is because a file will only contain a blank line
    # if it is the End of the File
    empty_string = ""

    # Open the file that the user has choosen
    with open(filename, "r", encoding="utf-8") as input_file:

        # Go through the file and add each line to a list called current_line
        # Go through until you reach an empty string
        # Blank lines include "\n" so it will only end once it reaches
        # a line that is empty
        current_line = input_file.readline()
        while current_line != empty_string :
            list_messages.append(current_line)
            current_line = input_file.readline()

        # Close the file after it has been read
        input_file.close()


    return list_messages


def write_messages(lines):
    """Write encrypted message to results.txt after it has been encrypted or decrypted

    Args:
        lines (string): The entire message from the file that the user declared

    Returns:
        No value is returned
    """

    # Open results.txt for writing and then paste in the encrypted messages
    # Note, writing to a file that doesn't exist will create it
    with open("results.txt", "w", encoding="utf-8") as input_file:
        input_file.write(lines)

        # Close the file after it has been written into
        input_file.close()

def is_file(filename):
    """Check if file the user selected exists

    Args:
        filename (string): The file that the user selected as it contains a message

    Returns:
        Boolean: Returns False if the file name the user specified doesn't exist
    """

    # Check if the file exists using os.path.exists
    # This was declared at the top of the file
    file_exists = os.path.exists(filename)

    # If the file the user specified exists, then do this
    if file_exists is True:
        return True

    # If the file doesn't exist, then return a false
    return False


def message_or_file():
    """Check if user wants to input a message using the console or a file

    Returns:
        mode (string): Returns what mode the user wishes to use (encrypt/decrypt)
        message (string): Returns the message that the user wishes to encrypt/decrypt
        filename (string): Returns the name of the file that the user wants encrypting/decrypting
        shift (int): Returns the shift number that is used when moving up or down the alphabet
    """

    # Declare variables for later use.
    filename = None
    message = None
    shift = None

    # Ask user if they would like to encrypt or decrypt their message
    print("Would you like to encrypt (e) or decrypt (d)?")
    mode = str(input())

    # Loop until the user inputs e or d
    while mode not in ("e", "d"):
        print("Invalid mode, please enter 'e' or 'd'")
        print("Please type (e) for encrypt or (d) for decrypt")
        mode = str(input())

    # Ask user if they would like to read from the console or a file
    print("Would you like to read from the console (c) or a file (f)?")
    console_or_file = str(input())

    # Check user input if c or f is used. Otherwise continue to prompt for it
    while console_or_file not in ("c", "f"):
        print("Would you like to read from the console (c) or a file (f)?")
        console_or_file = str(input())


    # Check if user select c or f
    if console_or_file == "c":

        # If the user selected console, then continue on and return back
        # to the enter_message function
        filename = None

    else:

        # is_file will check if there is a file with the name from filename
        # If there isn't then it will return False, and continue until a file is found
        check_for_file = False
        while check_for_file is False:

            # Ask user for the name of the file to read from
            print("Enter the name of the file you wish to open: ")
            filename = str(input())

            # is_file will return a True or False. If the statement is
            # True then it will exit the loop. If it is
            # False then it will stay in the loop asking for a filename
            check_for_file = is_file(filename)

    return (mode, message, filename, shift)

def main():
    """The main function of the program. This is what will run on startup.

    Returns:
        No value is returned
    """

    #print welcome message and then return to main()
    welcome()

    # Declare it as True, as it will be used to loop through the main program
    # until it is deemed False. In which then the program will break and exit
    loop_through_program = True
    while loop_through_program:

        # Run through the enter_message function then return
        # and assign the mode, message, and shift number
        mode, message, shift = enter_message()

        # Check if the user wants to encrypt or decrypt, then run the appropriate function
        if mode == "e":
            lines = encrypt(message, shift)
            print("The encrypted message is: ", lines)

        # If mode does not equal "e", then it must be "d", the decryption mode
        else:
            lines = decrypt(message, shift)
            print("The decrypted message is:", lines)

        # Write the new message to results.txt
        write_messages(lines)

        # prompt the user if they would like to encrypt or decrypt again
        print("Would you like to encrypt or decrypt another messages? (y/n)")
        user_y_n = str(input())
        while user_y_n not in ("y", "n"):
            print("Would you like to encrypt or decrypt another messages? (y/n)")
            user_y_n = str(input())

        if user_y_n == "n":
            print("Thank you for using the program, goodbye!")
            break


# Program execution begins here
# Checks if caesar.py is launched directly, if so then run main()
# If caesar.py is ran as part of a module, then do not run main()
# https://www.pythontutorial.net/python-basics/python-__name__/
if __name__ == '__main__':
    main()
