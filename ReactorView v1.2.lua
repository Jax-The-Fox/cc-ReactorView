--Thank you for downloading ReactorView v1.2 by JaxTheFox - Now with chat commands!
--Documentation can be found at: https://github.com/Jax-The-Fox/cc-ReactorView

--attaching peripherals
local cbox = peripheral.wrap("top")
local reactor = peripheral.wrap("back")
local reactorIn = peripheral.wrap("")
local reactorOut = peripheral.wrap("")
local m = peripheral.wrap("")

--default reactor status
local status = "Operating normally."

--functions
function clearMonitor()
	--reset terminal
    m.clear()
    m.setCursorPos(2,2)
    m.setTextColor(colors.white)
    m.setBackgroundColor(colors.black)
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

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


--main loop, happens 10 times per second
while true do
parallel.waitForAny(
function()
		--clear monitor and terminal
		clearMonitor()
		term.clear()
	
		--assign reactor info to 'rinfo' table
		local rinfo = reactor.getReactorInfo()    
	
		--print computer name and RF/t
		m.setBackgroundColor(colors.black)
		m.setTextColor(colors.blue)
		m.write(os.getComputerLabel())
	
		if rinfo.status == "running" then
			statusColor = colors.green
		else
			statusColor = colors.red
		end
	
		m.setTextColor(colors.white)
		m.write(" is: ")
		m.setTextColor(statusColor)
		m.write(rinfo.status)
	
		m.setCursorPos(2,5)
	
		m.setTextColor(colors.white)
		m.write("Gain: ")
	
		m.setTextColor(colors.red)
		m.write(rinfo.generationRate - reactorIn.getFlow() .. " RF/t")
	
		--underline for the top bar
		m.setTextColor(colors.white)
		m.setCursorPos(2,3)
		for i=1,29 do
			m.write("-")
		end
	
		--print field strength percentage
		m.setTextColor(colors.white)
		m.setBackgroundColor(colors.black)
		m.setCursorPos(2,8)
	
		local saturation = ((rinfo.energySaturation / rinfo.maxEnergySaturation) * 100)
               
		m.write("Saturation:       ")
			   
		if saturation >= 25 then
			color = colors.green
		elseif saturation >= 10 and saturation < 25 then
			color = colors.orange
			status = "Saturation low."
		elseif saturation < 10 then
			color = colors.red
			status = "Saturation critical!"
		end
	
		m.setTextColor(color)
		m.write(round(saturation, 3) .. "%")
    
		barGraph(2, 9, saturation, color)
	
		--print temperature
		m.setTextColor(colors.white)
		m.setBackgroundColor(colors.black)
		m.setCursorPos(2,11)
	
		local temperature = (rinfo.temperature)
    
		m.write("Temperature:      ")
	
		if temperature < 7500 then
			color = colors.green
		elseif temperature >= 7500 and temperature < 8000 then
			color = colors.orange
			status = "Temperature high."
		elseif temperature >= 8000 then
			color = colors.red
			status = "Temperature critical!"
		end
	
		m.setTextColor(color)
		m.write(temperature .. "C")
    
		barGraph(2, 12, round(((temperature / 8000) * 100), 1), color)
	
		--print field strength percentage
		m.setTextColor(colors.white)
		m.setBackgroundColor(colors.black)
		m.setCursorPos(2,14)
	
		local fieldStrength = ((rinfo.fieldStrength / rinfo.maxFieldStrength) * 100)
               
		m.write("Field Strength:   ")
			   
		if fieldStrength >= 25 then
			color = colors.green
		elseif fieldStrength >= 10 and fieldStrength < 25 then
			color = colors.orange
			status = "Shield level low."
		elseif fieldStrength < 10 then
			color = colors.red
			status = "Shield level critical!"
		end
	
		m.setTextColor(color)
		m.write(round(fieldStrength, 3) .. "%")
    
		barGraph(2, 15, fieldStrength, color)
	
		--print fuel remaining
		m.setTextColor(colors.white)
		m.setBackgroundColor(colors.black)
		m.setCursorPos(2,17)
	
		local fuelRemaning = (100 - ((rinfo.fuelConversion / rinfo.maxFuelConversion) * 100))
                
		m.write("Fuel Remaining:   ")			
				
		if fuelRemaning >= 20 then
			color = colors.green
		elseif fuelRemaning < 20 and fuelRemaning > 5 then
			color = colors.orange
			status = "Fuel level low."
		elseif fuelRemaning >= 5 then
			color = colors.red
			status = "Fuel level critical!"
		end
    
		m.setTextColor(color)
		m.write(round(fuelRemaning, 3) .. "%")
	
		barGraph(2, 18, fuelRemaning, color)
	
		--print messages to user
		m.setTextColor(colors.white)
		m.setBackgroundColor(colors.black)
		m.setCursorPos(2, 4)
	
		m.write("Info: ")
		if status == "Operating normally." then
			messagecolor = colors.green
		elseif status == "Fuel level low." or status == "Shield level low." or status == "Temperature high." or status == "Saturation low." then
			messagecolor = colors.orange
		elseif status == "Fuel level critical!" or status == "Shield level critical!" or status == "Temperature critical!" or status == "Saturation critical!" then
			messagecolor = colors.red
		end
	
		m.setTextColor(messagecolor)
		m.write(status)
	
		status = "Operating normally."
	
		--calculate remaining time
		ticksRemaining = (((rinfo.maxFuelConversion - rinfo.fuelConversion) * 1000000) / rinfo.fuelConversionRate)
	
		m.setCursorPos(2, 6)
		m.setTextColor(colors.white)
		m.setBackgroundColor(colors.black)
		m.write("T- ") 
	
		m.setTextColor(colors.red)
		m.write(round(ticksRemaining / 72000, 2))
	
		m.setTextColor(colors.white)
		m.write(" hours remain")
	
		--print debug to terminal
		term.setCursorPos(1,1)
		term.setTextColor(colors.gray)
		print("ReactorView v1.2 by JaxTheFox - Now with chat commands!")
	
		term.setTextColor(colors.white)
		for k, v in pairs (rinfo) do
			print(k.. ": ".. tostring(v))
		end
	
		print("ticksRemaining: " .. ticksRemaining)
	
		--delay to avoid too many operations
		os.sleep(0.1)
	end,
	
	--chat commands
	function()
		local rinfo = reactor.getReactorInfo()
		local chatRange = 1000000
		
		--search for 'command' type chat event
		local command = {os.pullEvent("command")}
		local chatargs = command[3]
		
		--defining the command, query and change list
		local commandList =  "'shutdown' or 'activate'"
		local queryList = "'temperature', 'fieldStrength', 'energySaturation', 'fuelConversion', 'generationRate', 'fieldDrainRate', 'fuelConversionRate', 'status' or 'all'"
		local changeList = "'containmentPower' or 'outputPower'"
		
		if chatargs[1] == tostring(os.getComputerLabel()) or chatargs[1] == "reactor" then
			--commands to start or stop the reactor
			if chatargs[2] == "command" then
				if chatargs[3] == "shutdown" then
					reactor.stopReactor()
				elseif chatargs[3] == "activate" then
					reactor.activateReactor()
				else 
					cbox.tell(command[2], "Invalid Entry, try: " .. commandList, chatRange, true, os.getComputerLabel())
				end
			--possible value queries
			elseif chatargs[2] == "query" then 
				if chatargs[3] == "temperature" then
					cbox.tell(command[2], "Current core temperature: " .. tostring(rinfo.temperature), chatRange, true, os.getComputerLabel())
				elseif chatargs[3] == "fieldStrength" then
					cbox.tell(command[2], "Current containment field strength: " .. tostring(rinfo.fieldStrength), chatRange, true, os.getComputerLabel())
				elseif chatargs[3] == "energySaturation" then
					cbox.tell(command[2], "Current energy saturation: " .. tostring(rinfo.energySaturation), chatRange, true, os.getComputerLabel())
				elseif chatargs[3] == "fuelConversion" then
					cbox.tell(command[2], "Current fuel conversion: " .. tostring(rinfo.fuelConversion), chatRange, true, os.getComputerLabel())
				elseif chatargs[3] == "generationRate" then
					cbox.tell(command[2], "Current gross RF/t: " .. tostring(rinfo.generationRate), chatRange, true, os.getComputerLabel())
				elseif chatargs[3] == "fieldDrainRate" then
					cbox.tell(command[2], "Current RF/t used by containment field: " .. tostring(rinfo.fieldDrainRate), chatRange, true, os.getComputerLabel())
				elseif chatargs[3] == "fuelConversionRate" then
					cbox.tell(command[2], "Current fuel conversion rate: " .. tostring(rinfo.fuelConversionRate), chatRange, true, os.getComputerLabel())
				elseif chatargs[3] == "status" then
					cbox.tell(command[2], "Reactor status: " .. tostring(rinfo.status), chatRange, true, os.getComputerLabel())
				elseif chatargs[3] == "all" then
					cbox.tell(command[2], "Current core temperature: " .. tostring(rinfo.temperature) .. "C", chatRange, true, os.getComputerLabel())
					cbox.tell(command[2], "Current containment field strength: " .. tostring((rinfo.fieldStrength / rinfo.maxFieldStrength) * 100) .. "%", chatRange, true, os.getComputerLabel())
					cbox.tell(command[2], "Current energy saturation: " .. tostring((rinfo.energySaturation / rinfo.maxEnergySaturation) * 100) .. "%", chatRange, true, os.getComputerLabel())
					cbox.tell(command[2], "Current fuel conversion: " .. tostring((rinfo.fuelConversion / rinfo.maxFuelConversion) * 100) .. "%", chatRange, true, os.getComputerLabel())
					cbox.tell(command[2], "Current gross RF/t: " .. tostring(rinfo.generationRate / 1000) .. "KRF/t", chatRange, true, os.getComputerLabel())
					cbox.tell(command[2], "Current RF/t used by containment field: " .. tostring(rinfo.fieldDrainRate) .. "RF/t", chatRange, true, os.getComputerLabel())
					cbox.tell(command[2], "Current fuel conversion rate: " .. tostring(rinfo.fuelConversionRate) .. "nb/t", chatRange, true, os.getComputerLabel())
					cbox.tell(command[2], "Current reactor status: " .. tostring(rinfo.status), chatRange, true, os.getComputerLabel())
				else 
					cbox.tell(command[2], "Invalid Entry, try: " .. queryList, chatRange, true, os.getComputerLabel())
				end
			--reactor in and out RF/t values to change
			elseif chatargs[2] == "change" then
				if chatargs[3] == "containmentPower" then
					if tonumber(chatargs[4]) ~= nil and tonumber(chatargs[4]) > 0 then
						reactorIn.setSignalLowFlow(tonumber(chatargs[4]))
					else
						cbox.tell(command[2], "Invalid Entry, Please Enter Positive Integer.", chatRange, true, os.getComputerLabel())
					end
				elseif chatargs[3] == "outputPower" then
					if tonumber(chatargs[4]) ~= nil and tonumber(chatargs[4]) > 0 then
						reactorOut.setSignalLowFlow(tonumber(chatargs[4]))
					else
						cbox.tell(command[2], "Invalid Entry, Please Enter Positive Integer.", chatRange, true, os.getComputerLabel())
					end
				else
					cbox.tell(command[2], "Invalid Entry, try: " .. changeList, chatRange, true, os.getComputerLabel())
				end
			else
				cbox.tell(command[2], "Invalid Entry, try: 'command', 'query' or 'change'", chatRange, true, os.getComputerLabel())
			end --chatargs[2] end
		end --chatargs[1] end
	end --function end
	) --close parallel
end -- while true do end
