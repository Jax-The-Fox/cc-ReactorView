# cc-ReactorView
ReactorView is a script for ComputerCraft designed to control and display information from a Draconic Evolution reactor.

It can be downloaded directly to a computer with the command: 

pastebin get WvYZ091b startup



BEFORE YOU START:
There are a few values that need to be set in the script before you can run it, otherwise it will return an error:

reactorIn = peripheral.wrap("") the text in the quotes needs to be set to the exact name of the modem connected to the flux gate on the energy injector

reactorOut = peripheral.wrap("") the text in the quotes needs to be set to the exact name of the modem connected to the flux gate on the output of the reactor

m = peripheral.wrap("") the text in the quotes needs to be set to the exact name of th emodem connected to the 3x3 monitor setup

playerWhitelist = {""} has to have all the authorized players added to it that are allowed to use the chat commands. Additional players can be added with a comma, folled by another set of quotes. The player name needs to be exact, and is case-sensitive. Chat commands can be found below, and are also read to the user if improper syntax is used.

Understanding The Interface

![2022-07-31_01 12 49](https://user-images.githubusercontent.com/110324509/182014622-ec7fe640-a0aa-4c34-ba68-2bba1db140ec.png)

I will be using the text in the image above as an example

'Core-1' is the computer label. That is the name that is shown in the top left, and is what you would call in the '\Core-1' command to query one reactor

'running' is the state of the reactor. This can have several other states, like 'Cooling Down' or 'Inactive'. They are all the same as what is shown in the reactor GUI

'AUTO' is the state of the program. It can be either 'AUTO' or 'MANL', and will mean the reactor is being controlled or not.

'Info:' can display messages to the user about the state of the reactor. It can show messages like 'Temperature High.' or 'Saturation Critical!' and gives insight into any issues the reactor may be facing

'Gain:' is the net RF/t the reactor is making after factoring in the amount taken for the shielding. The '0/s' after that is the amount the RF/t is changing per second.

'T-' is an estimation of the amount of time the reactor will last on the current fuel. This number can change based on current fuel usage and saturation.
The four graphs with values show the current Saturation, Temperature, Field Strength and Fuel remaining, respectively, and can change color if they get too high or low.



By default, it will allow the use of PeripheralsPlusOne's Chat Box to control the reactor from Minecraft's in-game chat using the following commands:
(In v1.3, commands can only be executed by someone that is in the whitelist)

'\reactor' or '\'computer name'' will bring up more information in chat about what can be done. Both do the same thing, but 'reactor' will query all computers running the script, while using the computer name instead will only query that computer.

'\reactor query' will allow querying of any of these values from the reactor: 'temperature', 'fieldStrength', 'energySaturation', 'fuelConversion', 'generationRate', 'fieldDrainRate', 'fuelConversionRate', 'status' or 'all'

'\reactor change' will allow changing of either the power going into, or out of the reactor, as well as toggling automatic control

'\reactor command' will allow you to either shutdown or activate the reactor

'\reactor scram' will immediately shutdown the reactor, regardless of current state

All testing was done with Minecraft version 1.12.2, CC-Tweaked version 1.89.2, Draconic Evolution version 2.3.28.354 and PeripheralsPlusOne version 1.1 build T58.
I hold no responsibility for any damage to your world caused by a reactor controlled by this script. Please report any explosions and the cause to the issues page here on GitHub.

TODO:
-make a port for Extreme Reactors
