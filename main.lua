otherImgs={}
otherImgs.cursors={}
otherImgs.cursors.default=love.graphics.newImage("res/cursor_default.png")
otherImgs.cursors.kill=love.graphics.newImage("res/cursor_kill.png")
otherImgs.cursors.assignRoom=love.graphics.newImage("res/cursor_assignRoom.png")

otherImgs.icons={}
otherImgs.icons.newsIcon=love.graphics.newImage("res/newsIcon.png")
otherImgs.icons.unopenedEmailIcon=love.graphics.newImage("res/unopenedEmailIcon.png")
otherImgs.icons.openedEmailIcon=love.graphics.newImage("res/openedEmailIcon.png")


--STARTUP
function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	require 'util'

	require 'setup'
	T=require 'notTracery'
	require 'mortals'
	require 'time'
	require 'motel'
	require 'ui'
	require 'menu'
	require 'saveload'
	love.filesystem.setIdentity("MotelSimulator98")
	gameBooted=true
	bootText="Starting boot procedure..."
	bootTextLines=1;
	bootTimer=0
	debug=false
	inGame=false

	--love.mouse.setVisible(false)
	mouseX=0
	mouseY=0
	--mortalInterval=400
	--mortalIntervalMin=300


	mortalTimeMin=300
	mortalTimeMax=600
	--mortalTimeMin=1
	--mortalTimeMax=6
	--mortalTime=love.math.random(mortalTimeMin,mortalTimeMax)
	--mortalTime=love.math.random(200,400)
	mortalTime=love.math.random(mortalTimeMin,mortalTimeMax)
	--mortalTime=10
	paused=false
	pauseIcon="❚❚"
	inspectPlayer=true




	grayLevel=0
	moonY=0
	sunY=250
	celestialMax=250
	celestialSpeed=7
	grayLevelMax=50

	moonImg=love.graphics.newImage("res/moon.png")
	sunImg=love.graphics.newImage("res/sun.png")


  fontDefault=love.graphics.newFont("res/Arial-Unicode-Regular.ttf",15)
  fontSpooky=love.graphics.newFont("res/SpencersSpookyFontMONO.ttf",25)
  love.graphics.setFont(fontSpooky)
	fontCharWidth=13
	fontCharHeight=18


	newsFeedWidth=400
	checkNewsStories()
	upgradesWidth=((window.w-newsFeedWidth)/2)-40
	upgradesXPos=newsFeedWidth+60+upgradesWidth
	upgradesYPos=window.h/2+60
	upgradesYOffset=0


	customersXPos=newsFeedWidth+40
	customersYPos=window.h/2+60
	customersYOffset=0

	customerLim=6
	--customerLim=20
	cleanSpeed=0.01

	newsFeedYOffset=0
	motelYOffset=0
	motelXOffset=200

  shadowXMax=280+motelXOffset+100
  shadowYMax=120+floors[1].height+motelYOffset+100
	--m=Mortal()
	--m:addReviewFrag(ReviewFragment("frag 1",5,1))
	--m:addReviewFrag(ReviewFragment("frag 2",1,0.5))
	--m:addReviewFrag(ReviewFragment("frag 3",2,0.8))
	--m:leave()

	--m=Mortal()
	--m:addReviewFrag(ReviewFragment("frag 1b",4,1))
	--m:addReviewFrag(ReviewFragment("frag 2b",4,0.5))
	--m:addReviewFrag(ReviewFragment("frag 3b",4,0.8))
	--m:leave()
end

function everyMS(ms)
	return math.floor(math.fmod(time2, ms))==0
end

tutorialMessagesShown={false,false,false,false}
function love.update(dt)
	if(gameBooted)then


		if(inGame)then
			if((not paused) and everyMS(1000))then
				--saveData()
			end
			--first messages
			if(not(tutorialMessagesShown[1]) and  time2>3)then
				tutorialMessagesShown[1]=true
				newNewsStory("New Motel Opens!","A new Motel has opened just off highway 5, the long-abandoned property was purchased by a plucky entrepreneur. Updates as business continues.")
			elseif(not(tutorialMessagesShown[2]) and  time2>100)then
					tutorialMessagesShown[2]=true
					newEmail("RE Motel Purchase","Hi, I'm the help around here. Give me a shout if you need anything, especially if you want to try to improve this place. Left click on a customer's name and then a room to book them in, or right click to automatically assign a room to them. -"..getHelpInitial())
			elseif(not(tutorialMessagesShown[3]) and  time2>1000)then
				tutorialMessagesShown[3]=true
				addToNewsFeed(Review("This is a review for the motel, customers will give you feedback and a rating, try to keep your rating up. Let's get you started with a nice 5 stars. -"..getHelpInitial(),5,nil))
			elseif(not(tutorialMessagesShown[4]) and  time2>2500)then
					tutorialMessagesShown[4]=true
					newEmail("RE Upgrades","If you want to get started with fixing this place up, I'd buy some upgrades with the cash you make. -"..getHelpInitial())
			end



			if(inBox(mouseX,mouseY,window.w-65,15,50,50))then
				pauseButtonSizeIncrease=4
			else
				pauseButtonSizeIncrease=0
			end
			if(inBox(mouseX,mouseY,window.w-65-100-15,15,100,50))then
				officeButtonSizeIncrease=4
			else
				officeButtonSizeIncrease=0
			end
			if(paused==false)then
				time=time+dt
				--if(debug==true)then time2=time2+1
				--else time2=time2+0.1 end
				--time2=time2+1
				time2=time2+dt*30
				u=getUpgrades()
				for k=1,#u do
					u[k]:update()
				end
				for k=1,#mortals do
					mortals[k]:update()
				end
				--if(everyMS(mortalInterval))then
				--love.window.showMessageBox("time2 vs mortaltime", Inspect(time2).."|"..Inspect(mortalTime), "info", true)
				if(math.floor(time2)==math.floor(mortalTime))then
					if(copNext)then
						newMortal("cop")
						copNext=false
					else
						newMortal()
					end
					--mortalInterval=mortalInterval*0.9
					--if(mortalInterval<mortalIntervalMin)then mortalInterval=mortalIntervalMin end

					mortalTime=time2+love.math.random(mortalTimeMin,mortalTimeMax)
				end
				updateProblems()
				if(time2>dayLen*7*4 and (not gameEnd))then
					winGame()
				end
			end
		else
			menu.update()
		end
	else
		loadData()
		bootTimer=bootTimer+1
		if(bootTimer>400)then gameBooted=true
		elseif(bootTimer>340)then  bootText=bootText.."\nERROR ANOMALY DETECTED || DO NOT COMPLETE BOOT PROCEDURE ||" bootTextLines=bootTextLines+1
		elseif(bootTimer==230)then bootText=bootText.."\nExorcising issues..." bootTextLines=bootTextLines+1
		elseif(bootTimer==150)then bootText=bootText.."\nFinding issues..." bootTextLines=bootTextLines+1
		elseif(bootTimer==100)then bootText=bootText.."\nLoading from disk..." bootTextLines=bootTextLines+1
		elseif(bootTimer==50)then bootText=bootText.."\nAllocating Memory..." bootTextLines=bootTextLines+1
	 end
	end
	if(loadDataOnFrameEnd)then loadData() loadDataOnFrameEnd=false end
end;

officeButtonSizeIncrease=0
pauseButtonSizeIncrease=0

function love.draw()
	if(gameBooted)then
		if(inGame)then
		love.graphics.setShader()
		--love.graphics.setShader(pixelShader)
		love.graphics.setCanvas(canvas)
		love.graphics.setColor(0,0,0,255)
		love.graphics.rectangle("fill", 0, 0, window.w, window.h)



		 love.graphics.setColor(255,255,255,255)
		 --love.graphics.print("Testing font",10,10)
		 --i=0
		 --while i<#"Testing font" do
			 --love.graphics.rectangle("line", 10+i*fontCharWidth, 10,fontCharWidth,fontCharHeight)
			 --i=i+1
		 --end
		 --love.graphics.rectangle("line", 10, 10, 12.5,15)
		 --textBoxHeight=drawTextInBox("123456789",fontCharWidth,fontCharHeight,10,20,fontCharWidth*5)


		 --m:getFinalReview(3):print(fontCharWidth,fontCharHeight,10,10,mReviewWidth)
		 drawNewsFeed(10,30,newsFeedYOffset,newsFeedWidth,window.h-20,fontCharWidth,fontCharHeight)
		 love.graphics.setColor(0,0,0,255)
		 love.graphics.rectangle("fill",0,0,newsFeedWidth,30)
		 love.graphics.setColor(255,255,255,255)
		 avgRating=getAvgRating()
		 if(newsFeedYOffset<0)then scrollToTopMessage="[BACK TO TOP]" else scrollToTopMessage="" end
		 love.graphics.print("Avg Rating "..string.format("%.2f",avgRating),10,10)
		 love.graphics.setFont(fontDefault)
		 love.graphics.print(getRatingText(avgRating).."   "..scrollToTopMessage,220,7)
		 love.graphics.setFont(fontSpooky)

		 love.graphics.rectangle("line", newsFeedWidth+30, 10, window.w-newsFeedWidth-40, window.h/2-10)
	 	 --love.graphics.setColor(255,255,255,(55*(getHours(time2)/24)))
	 	 love.graphics.setColor(0,0,0,255)
	 	 love.graphics.rectangle("fill", newsFeedWidth+30, 10, window.w-newsFeedWidth-40, window.h/2-10)

		 local stencil = function()
		   love.graphics.rectangle("fill", newsFeedWidth+30, 60+fontCharHeight+5, window.w-newsFeedWidth-40, window.h/2-85)
		 end

		 love.graphics.stencil(stencil,"replace",1)
		 love.graphics.setStencilTest("greater", 0)
		 --love.window.showMessageBox("motel size", string.format("%d x %d",window.w-newsFeedWidth-40, window.h/2-10), "info", true)
		 --love.graphics.setColor(255, 0, 0, 255)




			 local stencil = function()
			   love.graphics.rectangle("fill", newsFeedWidth+30, 60+fontCharHeight+5, window.w-newsFeedWidth-40, window.h/2-85)
			 end

			 love.graphics.stencil(stencil,"replace",1)

			 --if(math.fmod(time2,dayLen/4)==0)then love.window.showMessageBox("night", Inspect(getNightTime()), "info", true) end
			 	grayLevelMax=50-(50*evilPerc)
				 if(getNightTime())then
					if(grayLevel<=0) then grayLevel=0
					else grayLevel=grayLevel-1 end


					if(within(sunY,celestialMax,celestialSpeed/2)) then sunY=celestialMax
	  			else sunY=sunY+((sunY/celestialMax)+0.3)*celestialSpeed end

					if(within(moonY,0,celestialSpeed/2)) then moonY=0
	  			else moonY=moonY-((moonY/celestialMax)+0.3)*celestialSpeed end

				 	love.graphics.setColor(grayLevel,grayLevel,grayLevel,255)
			 	 	love.graphics.rectangle("fill", 0, 0, window.w, window.h)
				else
					 if(grayLevel>=grayLevelMax) then grayLevel=grayLevelMax
					 else grayLevel=grayLevel+1 end

					if(within(moonY,celestialMax,celestialSpeed/2)) then moonY=celestialMax
					else moonY=moonY+((moonY/celestialMax)+0.3)*celestialSpeed end


	 				if(within(sunY,0,celestialSpeed/2)) then sunY=0
	   			else sunY=sunY-((sunY/celestialMax)+0.3)*celestialSpeed end



					love.graphics.setColor(grayLevel,grayLevel,grayLevel,255)
				 	love.graphics.rectangle("fill", 0, 0, window.w, window.h)
				end
				--draw moon
				love.graphics.setColor(255,255*(1-evilPerc),255*(1-evilPerc),255)
				--love.graphics.circle("line", window.w-50, 100+motelYOffset*1.25+moonY, 14+(10*evilPerc))
				moonRad=1+(1.2*evilPerc)
				love.graphics.draw(moonImg,window.w-50, 100+motelYOffset*1.25+moonY,0,moonRad,moonRad,moonImg:getWidth()/2,moonImg:getHeight()/2)

				--draw sun
				love.graphics.setColor(255,255,255,255*(1-evilPerc))
				--love.graphics.circle("fill", window.w-50, 100+motelYOffset*1.25+sunY, 20-(19*evilPerc))
				sunRad=(1-evilPerc)*2
				love.graphics.draw(sunImg,window.w-50, 100+motelYOffset*1.25+sunY,0,sunRad,sunRad,sunImg:getWidth()/2,sunImg:getHeight()/2)

		 love.graphics.setColor(255, 255, 255, 255)
		 --M.print(newsFeedWidth+125, 230+motelYOffset,5,fontCharWidth,fontCharHeight)
		 M.print(newsFeedWidth+motelXOffset, 230+motelYOffset,5,fontCharWidth,fontCharHeight)

		 if(getNightTime())then

			 love.graphics.setColor(255, 255, 255, 150)
			 love.graphics.circle("fill", mouseX,mouseY,flashlightRad)
			 love.graphics.setColor(255, 255, 255, 255)


			  local stencil = function()
			    love.graphics.circle("fill", mouseX,mouseY,flashlightRad)
			  end

			  love.graphics.stencil(stencil,"replace",1)
			  love.graphics.setStencilTest("greater", 0)

				--stuff appear flashlight


			  love.graphics.stencil(stencil,"invert",1)

				--stuff disappear in flashlight



			end


		  local stencil = function()
					love.graphics.rectangle("fill", newsFeedWidth+30, 10, window.w-newsFeedWidth-40, window.h/2-10)
		  end
		  love.graphics.stencil(stencil,"replace",1)
		  love.graphics.setStencilTest("greater", 0)
		 --love.graphics.print("Time "..Inspect(time2), newsFeedWidth+40, 20)
		 for k=1,#mortals do
			 mortals[k]:draw(0,motelYOffset)
		 end


		 	love.graphics.setStencilTest()
		 love.graphics.print(getDateTextFull(time2), newsFeedWidth+40, 20)
		--love.graphics.print(getDateTextFull(time2).."           "..time2, newsFeedWidth+40, 20)

		 drawClock(window.w-130-100, 45, 30, getHours(time2),math.fmod(getHours(time2),1)*60,true)

		 if(debug)then
		 	love.graphics.print(string.format("$%.2f (%f evil)",money,evilPerc), newsFeedWidth+40, 40)
		else
		 	love.graphics.print(string.format("$%.2f %f",money,time2), newsFeedWidth+40, 40)
	 	end
		if(hasAppeared("No AC") or debug)then
			love.graphics.print(string.format("Number of occupants %d of %d (Temp %fC)",howManyMortalsStaying(),getRoomNo(),getTemperature()), newsFeedWidth+40, 60)
		else
			love.graphics.print(string.format("Number of occupants %d of %d",howManyMortalsStaying(),getRoomNo()), newsFeedWidth+40, 60)
		end


		love.graphics.rectangle("line", newsFeedWidth+30, 10, window.w-newsFeedWidth-40, window.h/2-10)
		 --love.graphics.setStencilTest()

		 --draw upgrades
		 love.graphics.rectangle("line", newsFeedWidth+30, window.h/2+10, window.w-newsFeedWidth-40, window.h/2-20)
		 love.graphics.print("Upgrades", upgradesXPos,upgradesYPos-40)
		 drawUpgrades(upgradesXPos,upgradesYPos,upgradesYOffset,upgradesWidth, window.h/2-40,fontCharWidth,fontCharHeight)

		 --draw customers
			if(evilPerc>0.9)then
				love.graphics.print("Potential Sacrifices", customersXPos,customersYPos-40)
			else
				love.graphics.print("Potential Customers", customersXPos,customersYPos-40)
			end
	 	 drawCustomers(customersXPos,customersYPos,customersYOffset,upgradesWidth, window.h/2-40,fontCharWidth,fontCharHeight)



		 love.graphics.setFont(fontDefault)
		 love.graphics.setColor(255,255,255,255)

		 love.graphics.rectangle("line", window.w-65-pauseButtonSizeIncrease/2,15-pauseButtonSizeIncrease/2,50+pauseButtonSizeIncrease,50+pauseButtonSizeIncrease)
		 love.graphics.print(pauseIcon,window.w-65+20,15+15)

		 love.graphics.setFont(fontSpooky)

		 love.graphics.rectangle("line", window.w-65-100-15-officeButtonSizeIncrease/2,15-officeButtonSizeIncrease/2,100+officeButtonSizeIncrease,50+officeButtonSizeIncrease)
		 love.graphics.print("Office",window.w-65-100-15+10,15+15)





		love.graphics.setColor(255, 255, 255, 255)

		--experimentShader:send("t",time)
		love.graphics.setFont(fontDefault)
		--if(debug==true)then love.graphics.print("time to next mortal: "..mortalTime.." vs t: "..time2.."\n"..shadowYMax.."\n"..Inspect(shadows),1200,100) end

		love.graphics.setFont(fontSpooky)



		love.graphics.setCanvas()
		flashlightShader:send("w",window.w)
		flashlightShader:send("h",window.w)
		flashlightShader:send("x",mouseX)
		flashlightShader:send("y",mouseY)
		flashlightShader:send("rad",flashlightRad)
		flashlightShader:send("bleed",0.4)
		flashlightShader:send("strength",0.7)
		love.graphics.setShader(flashlightShader)
		love.graphics.setShader(pixelShader)
		love.graphics.draw(canvas)
		else
			love.graphics.setShader(pixelShader)
			vingetteShader:send("w",window.w)
			vingetteShader:send("h",window.w)
			vingetteShader:send("x",bulb.x)
			vingetteShader:send("y",bulb.y)
			vingetteShader:send("light_on",bulb.on)
			love.graphics.setShader(vingetteShader)
			love.graphics.setCanvas(canvas)
			menu.draw()
			love.graphics.setCanvas()
			love.graphics.setShader(pixelShader)
			love.graphics.draw(canvas)
		end
	else
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.rectangle("fill", 0, 0, window.w, window.h)
		love.graphics.setColor(255,255,255,255)
		if(math.fmod(math.floor(bootTimer/6),2)==0)then bootTextUnderscore="!" else bootTextUnderscore="" end
		love.graphics.print(bootText..bootTextUnderscore,40,window.h-40-(bootTextLines*fontCharHeight))
	end

	love.graphics.setColor(255, 255, 255, 255)


	drawMenuBoxesQueued()

	--draw cursor
	love.graphics.setColor(255, 255, 255, 255)
	if(cursorState=="kill")then
		--love.graphics.setColor(255, 0, 0, 255)
		--love.graphics.ellipse("fill",mouseX,mouseY,10,10)
		love.graphics.draw(otherImgs.cursors.kill, mouseX, mouseY, 0, 3, 3, otherImgs.cursors.kill:getWidth()/2, otherImgs.cursors.kill:getHeight()/2)
	elseif(cursorState=="assignRoom")then
		--love.graphics.setColor(0, 255, 0, 255)
		--love.graphics.ellipse("fill",mouseX,mouseY,10,10)
		love.graphics.draw(otherImgs.cursors.assignRoom, mouseX, mouseY, 0, 1, 1, otherImgs.cursors.assignRoom:getWidth()/2, 0)
	else
	 love.graphics.draw(otherImgs.cursors.default, mouseX, mouseY, 0, 1, 1, 0,0)
	end

	--love.graphics.print(Inspect(mortalTypes),400,100)
end

function togglePause()
	--saveData()
	if(paused==true)then paused=false pauseIcon="❚❚" else paused=true pauseIcon="▶" end
end

cursorState=nil
function love.mousepressed(x, y, button, isTouch)
	if(inGame)then
		if(button==1 or button==2)then
			if(inBox(mouseX,mouseY,-5,-5,newsFeedWidth,50))then newsFeedYOffset=0 end
			checkUpgradesCol(upgradesXPos,upgradesYPos,upgradesYOffset,upgradesWidth, window.h/2-40,fontCharWidth,fontCharHeight,mouseX,mouseY)
			checkCustomersCol(customersXPos,customersYPos,customersYOffset,upgradesWidth, window.h/2-40,fontCharWidth,fontCharHeight,mouseX,mouseY)

			if(inBox(mouseX,mouseY,window.w-65,15,50,50))then
				togglePause()
			end
			if(inBox(mouseX,mouseY,window.w-65-100-15,15,100,50))then
				togglePause()
				inGame=false
				cursorState=nil
				mortalSelected=nil
				customerSelected=nil
			end
		end

	else
		--menu

		menu.onClick()
	end
end

function love.mousereleased(x, y, button, isTouch)
	if(inGame)then
	else
		--menu

		menu.onUnclick()
	end
end

function love.mousemoved(x, y, dx, dy)
	mouseX=x
	mouseY=y
end
loadDataOnFrameEnd=false
function love.keypressed(key, scancode, isrepeat)
	if(key=="f9")then loadDataOnFrameEnd=true
	elseif(key=="f10") then resetData() love.load()
	elseif(key=="f5") then saveData() end
	if(inGame)then
		if(key=="r")then
			--love.load()
		elseif(key=="a")then
			evilPercAdd(0.1)
		elseif(key=="q")then
			--inspectPlayer=true
			--if(debug==false) then debug=true money=money+1000000 else debug=false end
		elseif(key=="1")then
			--newMortal("normal")
		elseif(key=="2")then
			--newMortal("cop")
		elseif(key=="3")then
			--newMortal("murderer")
		elseif(key=="up")then
				--checkScrollUp()
 			 checkScroll(5)
		elseif(key=="down")then
	 		 --checkScrollDown()
			 checkScroll(-5)
		elseif(key=="space")then
			togglePause()
		elseif(key=="f")then
			--addInvestigationProgress(0.05);
		end
	else
		--menu
		menu.keyPressed()
	end
end
function love.keyreleased(key)
	if(inGame)then
		if(key=="q")then
			inspectPlayer=false
			--msg("title",floors[1]:getVacantRooms())
		end
	else
		--menu
		menu.keyReleased()
	end
end

function love.wheelmoved(x, y)
	if(inGame)then
		 if y > 0 then
			 checkScroll(y)

		 elseif y < 0 then
			 checkScroll(y)

		 end
 	else
 		--menu
 	end
end

function checkScroll(yVal)
	yVal=yVal*20
	if(inBox(mouseX,mouseY,newsFeedWidth+30, window.h/2+10, window.w-newsFeedWidth-40, window.h/2-20))then
		local upgradeMin=#getAvailableUpgrades()*-10
		if(upgradeMin>-window.h/2)then upgradeMin=0 end
		upgradesYOffset=clamp(upgradesYOffset+yVal,upgradeMin,0)
	--newsfeed
	elseif(inBox(mouseX,mouseY,10,30,newsFeedWidth,window.h-20))then
		local newsFeedMin=#newsFeed*-100
		newsFeedYOffset=clamp(newsFeedYOffset+yVal,newsFeedMin,0)
	elseif(inBox(mouseX,mouseY,newsFeedWidth+30, 60+fontCharHeight+5, window.w-newsFeedWidth-40, window.h/2-85))then
		motelYOffset=clamp(motelYOffset+yVal,0,window.h/4)
	end
end

checkScrollDown=function()
	--upgrades
	 if(inBox(mouseX,mouseY,newsFeedWidth+30, window.h/2+10, window.w-newsFeedWidth-40, window.h/2-20))then
		 upgradesYOffset=clamp(upgradesYOffset-10,upgradesYOffset-10,0)
	 --newsfeed
	 elseif(inBox(mouseX,mouseY,10,30,newsFeedWidth,window.h-20))then
		 newsFeedYOffset=clamp(newsFeedYOffset-10,newsFeedYOffset-10,0)
	 elseif(inBox(mouseX,mouseY,newsFeedWidth+30, 60+fontCharHeight+5, window.w-newsFeedWidth-40, window.h/2-85))then
		 motelYOffset=clamp(motelYOffset-10,0,motelYOffset-10)
	 end
end

checkScrollUp=function()
	--upgrades
	if(inBox(mouseX,mouseY,newsFeedWidth+30, window.h/2+10, window.w-newsFeedWidth-40, window.h/2-20))then
		upgradesYOffset=clamp(upgradesYOffset+10,upgradesYOffset+10,0)
	--newsfeed
	elseif(inBox(mouseX,mouseY,10,30,newsFeedWidth,window.h-20))then
		newsFeedYOffset=clamp(newsFeedYOffset+10,newsFeedYOffset+10,0)
	elseif(inBox(mouseX,mouseY,newsFeedWidth+30, 60+fontCharHeight+5, window.w-newsFeedWidth-40, window.h/2-85))then
		motelYOffset=clamp(motelYOffset+10,0,#floors*floors[1].height)
	end
end
