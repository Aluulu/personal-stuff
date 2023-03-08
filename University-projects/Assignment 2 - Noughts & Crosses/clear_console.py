"""Clears the console by passing the clear command to a system process

    Windows: Uses 'cls' and 'clear'
    Linux: Uses 'clear'
"""

# This is used to access the client's console
import subprocess

def clear():
    """Clears the console by passing the 'clear' command to it
    """
    subprocess.run(["clear"], check=True)
