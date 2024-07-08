import os
import sys
import deeplabcut

print('---')
print("Running Python Script")
print('---')

commands = (sys.argv[1])
commands = commands.split(';')

for command in commands:
    eval(command) # runs string as function

print('---')
print ("Python Script Finished")
print('---')