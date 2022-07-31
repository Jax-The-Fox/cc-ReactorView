--Thank you for downloading ReactorView v1.3 by JaxTheFox! Now with Skynet!
--Documentation can be found at: https://github.com/Jax-The-Fox/cc-ReactorView

--CHANGABLE VALUES--------------------------------------------------------------------------------------------------------------------------------
--attaching peripherals (make sure the flux gates are set correctly, or the program will not work properly. it won't blow up, but will try to increase the field input RF, while lowering output RF).
local reactorIn = peripheral.wrap("")  --set the text in quotes to be the name of the modem connected to the reactor's energy injector flux gate.
local reactorOut = peripheral.wrap("") --set the text in quotes to be the name of the modem connected to the reactor's output flux gate.
local m = peripheral.wrap("")			  --set the text in quotes to be the name of the modem connected to the monitor (monitor should be 3x3 for best results)
local cbox = peripheral.wrap("top")				  --if you are using the default layout for peripherals, this should be set correctly. change according to your setup otherwise.
local reactor = peripheral.wrap("back")			  --if you are using the default layout for peripherals, this should be set correctly. change according to your setup otherwise.

--automode controls (these all control the perameters that the computer is allowed to change, and by how much).
local safeTemp = 7800        --DEFAULT = 7800. the computer is only allowed to change values when temp is below this number. HIGHLY recommended to keep at 7800 or below.
local safeShieldPercent = 25 --DEFAULT = 25. the computer is only allowed to change values when shield percentage is higher than this number.
local changeAmount = 2500    --DEFAULT = 2500. amount the computer will change the values by every cycle. HIGHLY recommended to keep it below 5000.
local cycleTime = 60         --DEFAULT = 60. time in seconds between computer checks (one cycle). HIGHLY recommended to be 60 seconds or higher.
local automode = false       --DEFAULT = false. whether the computer starts in auto mode or not.
local terminalDebug = true   --DEFAULT = true. toggles debug readout in the computer terminal, will show all reactor information.

--safety levels (affects colors of bars and values on the monitor, temp is in degrees and all others are in percentages)
local highTemp = 7800        --DEFAULT = 7800. the temperature at which the temperature display will change to orange
local critTemp = 7950        --DEFAULT = 7950. the temperature at which the temperature display will change to red
local shutdownTemp = 8000    --DEFAULT = 8000. the temperature at which the reator will automatically shut down (shielding requirements will increase expnentially after 8000C, and become impossible to sustain). 
local lowSaturation = 10     --DEFAULT = 10. the saturation level at which the saturation display will turn orange.
local critSaturation = 5     --DEFAULT = 5. the saturation level at which the saturation display will turn red.
local lowShield = 22.5       --DEFAULT = 22.5. the shield level at which the shield display will turn orange.
local critShield = 15        --DEFAULT = 15. the shield level at which the shield display will turn red.
local lowFuel = 5            --DEFAULT = 5. the fuel level at which the fuel display will turn orange.
local critFuel = 2           --DEFAULT = 2. the fuel level at which the fuel display will turn red.
local shutdownFuel = 1       --DEFAULT = 1. the fuel level at which the reactor will automatically shut down (at zero fuel, the reactor will explode). 

--chatbox values
local chatRange = 1000    --DEFAULT = 1000. the range at which the chat box can answer player queries, in blocks. may vary based on server/client config.
local enableChat = true   --DEFAULT = true. whether or not to use chat to query and control the reactor
local playerWhitelist = {""} --the players that are allowed to query and control the reactor
--DO NOT CHANGE VALUES BEYOND THIS POINT----------------------------------------------------------------------------------------------------------

reactorLabel = os.getComputerLabel()
local tickTime = (cycleTime * 10)
local RFchange = 0
local count = 0
local oldRF = 0
local change = 0
if automode == true then 
	local status = "Computer Control."
else
	local status = "Manual Control."
end

--FUNCTIONS
--simple function to round a number to a certain amount of decimals - credit to http://lua-users.org/wiki/SimpleRound
function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

--function to print out a percentage as a horizontal bar graph
function barGraph(xorig, yorig, fillpercent, color)
	--print bar background
	m.setTextColor(colors.gray)
	m.setBackgroundColor(colors.gray)
	m.setCursorPos(xorig, yorig)
	for i=1,27 do
		 m.write(" ")
	end
	
	--print filled part of the bar 
	m.setTextColor(color)
	m.setBackgroundColor(color)
	m.setCursorPos(xorig, yorig)
	for i=1,(fillpercent / 3.703) do
		m.write(" ")
	end
	
	--reset colors
	m.setTextColor(colors.white)
	m.setBackgroundColor(colors.black)
end

--functions end

--main loop, happens 10 times per second
while true do
	parallel.waitForAny(
		function()
			--clear monitor and terminal
			m.clear()
			m.setCursorPos(2,2)
			m.setTextColor(colors.white)
			m.setBackgroundColor(colors.black)
			term.clear()
	
			--read reactor info and assign to 'rinfo' table
			local rinfo = reactor.getReactorInfo()    
	
			--print computer name and RF/t
			m.setBackgroundColor(colors.black)
			m.setTextColor(colors.blue)
			m.write(reactorLabel)
	
			--color status text based on the status and print it out after the computer name on the top line
			if rinfo.status == "running" then
				statusColor = colors.green
			else
				statusColor = colors.red
			end
		
			m.setTextColor(colors.white)
			m.write(" is: ")
			m.setTextColor(statusColor)
			m.write(rinfo.status)
		
			--print out the mode of the computer in the top right of the monitor
			if automode == true then 
				m.setTextColor(colors.green)
				m.setCursorPos(25,2)
				m.write("AUTO")
			elseif automode == false then
				m.setTextColor(colors.red)
				m.setCursorPos(25,2)
				m.write("MANL")
			end
			
			--sets 'RFchange' to the difference in RF/t over the last second
			change = change + 1
			if change > 9 then 
				RFchange = (rinfo.generationRate - reactorIn.getFlow()) - oldRF
				oldRF = rinfo.generationRate - reactorIn.getFlow()
				change = 0 
			end
			
			--sets the color of the text based on if the rf/t/s change was up or down, or neither
			if RFchange > 0 then
				addColor = colors.green
				symbol = " +"
			elseif RFchange < 0 then
				addColor = colors.red
				symbol = " "
			elseif RFchange == 0 then
				addColor = colors.white
				symbol = " "
			end
			
			--print out the current net RF/t and the gain or loss in rf/t over the last second
			m.setCursorPos(2,5)
			m.setTextColor(colors.white)
			m.write("Gain: ")
			m.setTextColor(colors.blue)
			m.write(rinfo.generationRate - reactorIn.getFlow() .. " RF/t")
			m.setTextColor(addColor)
			m.write(symbol .. RFchange .. "/s")
	
			
			--dashed underline for the top bar
			m.setTextColor(colors.white)
			m.setCursorPos(1,3)
			for i=1,29 do
				m.write("-")
			end
	
			--SATURATION
			--get reactor energy saturation percentage, and assign to 'saturation', then set color based on the percentage
			local saturation = ((rinfo.energySaturation / rinfo.maxEnergySaturation) * 100)
            
			if saturation >= lowSaturation then
				color = colors.green
			elseif saturation >= critSaturation and saturation < lowSaturation then
				color = colors.orange
				status = "Saturation low."
			elseif saturation < critSaturation then
				color = colors.red
				status = "Saturation critical!"
			end
			
			--draw saturation on the monitor
			m.setTextColor(colors.white)
			m.setBackgroundColor(colors.black)
			m.setCursorPos(2,8)
			m.write("Saturation:       ")
			m.setTextColor(color)
			m.write(round(saturation, 3) .. "%")
			
			--create bar graph for value
			barGraph(2, 9, saturation, color)
			
			--TEMPERATURE
			--get reactor temperature and assign to 'temperature', then set color based on the value
			local temperature = (rinfo.temperature)
    
			if temperature < highTemp then
				color = colors.green
			elseif temperature >= highTemp and temperature < critTemp then
				color = colors.orange
				status = "Temperature high."
			elseif temperature >= critTemp then
				color = colors.red
				status = "Temperature critical!"
			end
		
			--draw temperature on the monitor
			m.setTextColor(colors.white)
			m.setBackgroundColor(colors.black)
			m.setCursorPos(2,11)
			m.write("Temperature:      ")
			m.setTextColor(color)
			m.write(temperature .. "C")
			
			--create bar graph for value
			barGraph(2, 12, round(((temperature / 8000) * 100), 1), color)
	
			--FIELD STRENGTH
			--get reactor field strength percentage, and assign to 'fieldStrength', then set color based on percentage
			local fieldStrength = ((rinfo.fieldStrength / rinfo.maxFieldStrength) * 100)
               
			if fieldStrength >= lowShield then
				color = colors.green
			elseif fieldStrength >= critShield and fieldStrength < lowShield then
				color = colors.orange
				status = "Shield level low."
			elseif fieldStrength < critShield then
				color = colors.red
				status = "Shield level critical!"
			end
	
			--draw field percentage on the monitor
			m.setTextColor(colors.white)
			m.setBackgroundColor(colors.black)
			m.setCursorPos(2,14)
			m.write("Field Strength:   ")
			m.setTextColor(color)
			m.write(round(fieldStrength, 3) .. "%")
    
			--create bar graph for value
			barGraph(2, 15, fieldStrength, color)
	
			--FUEL REMAINING
			--get remaining fuel percentage, and assign it to 'fuelRemaining', then set color based on percentage
			local fuelRemaning = (100 - ((rinfo.fuelConversion / rinfo.maxFuelConversion) * 100))			
				
			if fuelRemaning >= lowFuel then
				color = colors.green
			elseif fuelRemaning < lowFuel and fuelRemaning > critFuel then
				color = colors.orange
				status = "Fuel level low."
			elseif fuelRemaning >= critFuel then
				color = colors.red
				status = "Fuel level critical!"
			end
    
			--draw fuel remaining percentage on the monitor
			m.setTextColor(colors.white)
			m.setBackgroundColor(colors.black)
			m.setCursorPos(2,17)    
			m.write("Fuel Remaining:   ")
			m.setTextColor(color)
			m.write(round(fuelRemaning, 3) .. "%")
	
			--create bar graph for value
			barGraph(2, 18, fuelRemaning, color)
	
			--INFO SCREEN
			m.setTextColor(colors.white)
			m.setBackgroundColor(colors.black)
			m.setCursorPos(2, 4)
			m.write("Info: ")
			
			--set text color based on the status of the reactor, which is based on the current temp, saturation, shield and remaining fuel
			if status == "Manual Control." or status == "Computer Control." then
				messagecolor = colors.green
			elseif status == "Fuel level low." or status == "Shield level low." or status == "Temperature high." or status == "Saturation low." then
				messagecolor = colors.orange
			elseif status == "Fuel level critical!" or status == "Shield level critical!" or status == "Temperature critical!" or status == "Saturation critical!" then
				messagecolor = colors.red
			else
				messagecolor = colors.red
			end
	
			m.setTextColor(messagecolor)
			m.write(status)
	
			--set status back to default value, so that it doesn't get stuck in a different status. the value checking above will set the status before printing in the event it isn't operating normally
			if automode == false then
				status = "Manual Control."
			elseif automode == true then
				status = "Computer Control."
			end
	
			--calculate remaining time in game ticks and print it out to the monitor in hours
			local ticksRemaining = (((rinfo.maxFuelConversion - rinfo.fuelConversion) * 1000000) / rinfo.fuelConversionRate)
			
			m.setCursorPos(2, 6)
			m.setTextColor(colors.white)
			m.setBackgroundColor(colors.black)
			m.write("T- ") 
			m.setTextColor(colors.red)
			m.write(round(ticksRemaining / 72000, 2))
			m.setTextColor(colors.white)
			m.write(" hours remain")
	
			--print out my watermark to the terminal
			term.setCursorPos(1,1)
			term.setTextColor(colors.gray)
			print("ReactorView v1.3 by JaxTheFox - Now with Skynet!")
	
			--print debug information to the terminal if debug is enabled. if debug disabled, it will print out either manual or automatic mode to the terminal
			if terminalDebug == true then
				term.setTextColor(colors.white)
				
				--this prints out all info that is normally given by the getReactorInfo() method
				for k, v in pairs (rinfo) do
					print(k.. ": ".. tostring(v))
				end
				
				--this prints out my calculated values
				print("ticksRemaining: " .. ticksRemaining)
				print("cycleTime: " .. count)
			else
				if automode == true then 
					term.setTextColor(colors.green)
					term.setCursorPos(1,2)
					term.write("Running in automatic mode")
				elseif automode == false then
					term.setTextColor(colors.red)
					term.setCursorPos(1,2)
					term.write("Running in manual mode.")
				end
			end
	
			--REACTOR AUTOMATION
			if (automode == true) then
				--get current RF in and out of the reactor from the flux gates
				local rfOut = reactorOut.getSignalLowFlow()
				local rfIn = reactorIn.getSignalLowFlow()
				
				--increase 'count' for every computer cycle
				count = count + 1
			
				--if the count is above the threshold, the computer checks if the shield and temperature is safe, and will increase the output by 'changeAmount' if it is
				if (count > tickTime) and (rinfo.temperature < safeTemp) and (((rinfo.fieldStrength / rinfo.maxFieldStrength) * 100) > safeShieldPercent) then
					reactorOut.setSignalLowFlow(rfOut + changeAmount)
					count = 0
				end
    
				-- if the count is above the threshold and the computer is not able to increase output, the computer checks if the shield is safe, and will decrease the input by 'changeAmount' if it is
				if (count > (tickTime + 1)) and ((rinfo.fieldStrength / rinfo.maxFieldStrength) * 100) > safeShieldPercent then
					reactorIn.setSignalLowFlow(rfIn - changeAmount)
					count = 0
				end
			end
    
			--FAILSAFE
			--this will shut down the reactor if the temperature gets higher than 'shutdownTemp' or if the fuel gets lower than 'shutdownFuel'
			if rinfo.temperature > shutdownTemp then
				reactor.stopReactor()
				cbox.say("Over safety temperature, emergency shutdown started.", chatRange, true, reactorLabel)
			elseif (fuelRemaning) < shutdownFuel then
				reactor.stopReactor()
				cbox.say("Under safety fuel level, emergency shutdown started.", chatRange, true, reactorLabel)
			end
	
			--delay to avoid too many operations per second
			os.sleep(0.1)
		end,
	
		--CHATBOX COMMANDS
		function()
			if enableChat == true then 
				--get info from reactor
				local rinfo = reactor.getReactorInfo()
		
				--search for 'command' type chat event and assign it to 'command'
				local command = {os.pullEvent("command")}
				local chatargs = command[3]
				local player = command[2]
				
				--check if the player that is querying the computer is whitelisted
				for k, v in pairs (playerWhitelist) do
					if (v == player) then
						whitelisted = true
					else
						whitelisted = false
					end
				end
		
				--defining the command, query and change list
				local commandList =  "'shutdown' or 'activate'"
				local queryList = "'temperature', 'fieldStrength', 'energySaturation', 'fuelConversion', 'generationRate', 'fieldDrainRate', 'fuelConversionRate', 'status' or 'all'"
				local changeList = "'containmentPower', 'outputPower' or 'auto'"
		
				--check if querying player is whitelisted, if not, they will be told
				if whitelisted == true then
					if chatargs[1] == tostring(reactorLabel) or chatargs[1] == "reactor" then
						--commands to start or stop the reactor
						if chatargs[2] == "command" then
							if chatargs[3] == "shutdown" then
								reactor.stopReactor()
							elseif chatargs[3] == "activate" then
								reactor.activateReactor()
							else 
								cbox.tell(command[2], "Invalid Entry, try: " .. commandList, chatRange, true, reactorLabel)
							end
						--scram functions
						elseif chatargs[2] == "scram" then
							cbox.tell(command[2], "Shutting down reactor", chatRange, true, reactorLabel)
							reactor.stopReactor()
							automode = false
						--possible value queries
						elseif chatargs[2] == "query" then 
							if chatargs[3] == "temperature" then
								cbox.tell(command[2], "Current core temperature: " .. tostring(rinfo.temperature), chatRange, true, reactorLabel)
							elseif chatargs[3] == "fieldStrength" then
								cbox.tell(command[2], "Current containment field strength: " .. tostring(rinfo.fieldStrength), chatRange, true, reactorLabel)
							elseif chatargs[3] == "energySaturation" then
								cbox.tell(command[2], "Current energy saturation: " .. tostring(rinfo.energySaturation), chatRange, true, reactorLabel)
							elseif chatargs[3] == "fuelConversion" then
								cbox.tell(command[2], "Current fuel conversion: " .. tostring(rinfo.fuelConversion), chatRange, true, reactorLabel)
							elseif chatargs[3] == "generationRate" then
								cbox.tell(command[2], "Current gross RF/t: " .. tostring(rinfo.generationRate), chatRange, true, reactorLabel)
							elseif chatargs[3] == "fieldDrainRate" then
								cbox.tell(command[2], "Current RF/t used by containment field: " .. tostring(rinfo.fieldDrainRate), chatRange, true, reactorLabel)
							elseif chatargs[3] == "fuelConversionRate" then
								cbox.tell(command[2], "Current fuel conversion rate: " .. tostring(rinfo.fuelConversionRate), chatRange, true, reactorLabel)
							elseif chatargs[3] == "status" then
								cbox.tell(command[2], "Reactor status: " .. tostring(rinfo.status), chatRange, true, reactorLabel)
							elseif chatargs[3] == "all" then
								cbox.tell(command[2], "Current core temperature: " .. tostring(rinfo.temperature) .. "C", chatRange, true, reactorLabel)
								cbox.tell(command[2], "Current containment field strength: " .. tostring((rinfo.fieldStrength / rinfo.maxFieldStrength) * 100) .. "%", chatRange, true, reactorLabel)
								cbox.tell(command[2], "Current energy saturation: " .. tostring((rinfo.energySaturation / rinfo.maxEnergySaturation) * 100) .. "%", chatRange, true, reactorLabel)
								cbox.tell(command[2], "Current fuel conversion: " .. tostring((rinfo.fuelConversion / rinfo.maxFuelConversion) * 100) .. "%", chatRange, true, reactorLabel)
								cbox.tell(command[2], "Current gross RF/t: " .. tostring(rinfo.generationRate / 1000) .. "KRF/t", chatRange, true, reactorLabel)
								cbox.tell(command[2], "Current RF/t used by containment field: " .. tostring(rinfo.fieldDrainRate) .. "RF/t", chatRange, true, reactorLabel)
								cbox.tell(command[2], "Current fuel conversion rate: " .. tostring(rinfo.fuelConversionRate) .. "nb/t", chatRange, true, reactorLabel)
								cbox.tell(command[2], "Current reactor status: " .. tostring(rinfo.status), chatRange, true, reactorLabel)
							else 
								cbox.tell(command[2], "Invalid Entry, try: " .. queryList, chatRange, true, reactorLabel)
							end
						--reactor in and out RF/t values to change
						elseif chatargs[2] == "change" then
							--change the power going into and out of the reactor. if the player changes it while in automode, the reactor will change to manual control
							if chatargs[3] == "containmentPower" then
								if tonumber(chatargs[4]) ~= nil and tonumber(chatargs[4]) > 0 then
								reactorIn.setSignalLowFlow(tonumber(chatargs[4]))
								if automode == true then
									cbox.tell(command[2], "Switching to manual mode.", chatRange, true, reactorLabel)
								end
								automode = false
								else
								cbox.tell(command[2], "Invalid Entry, Please Enter Positive Integer.", chatRange, true, reactorLabel)
								end
							elseif chatargs[3] == "outputPower" then
								if tonumber(chatargs[4]) ~= nil and tonumber(chatargs[4]) > 0 then
									reactorOut.setSignalLowFlow(tonumber(chatargs[4]))
									if automode == true then
										cbox.tell(command[2], "Switching to manual mode.", chatRange, true, reactorLabel)
									end
									automode = false
								else
									cbox.tell(command[2], "Invalid Entry, Please Enter Positive Integer.", chatRange, true, reactorLabel)
								end
							--toggle computer control
							elseif chatargs[3] == "auto" then
								if chatargs[4] == "true" then
									automode = true
								elseif chatargs[4] == "false" then
									automode = false
								else
									cbox.tell(command[2], "Invalid Entry, try: 'true' or 'false'", chatRange, true, reactorLabel)
								end
							else
								cbox.tell(command[2], "Invalid Entry, try: " .. changeList, chatRange, true, reactorLabel)
							end
						else
							cbox.tell(command[2], "Invalid Entry, try: 'command', 'query', 'change' or 'scram'", chatRange, true, reactorLabel)
						end 
					end
				elseif whitelisted == false then
					cbox.tell(command[2], "You are not allowed to make that query. Please contact the computer owner to request access.", chatRange, true, reactorLabel)
				end
			end
		end
	)
end 