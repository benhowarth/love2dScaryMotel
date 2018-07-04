require 'util'
--STARTUP
function love.load()

	love.graphics.setDefaultFilter("nearest", "nearest")
	require 'setup'
	--love.mouse.setVisible(false)
	mouseX=0
	mouseY=0
	mortalInterval=400
	mortalIntervalMin=300
	paused=false
	pauseIcon="❚❚"
	inspectPlayer=true

	upgradesYOffset=0
	newsFeedYOffset=0
	motelYOffset=0

	T=require 'notTracery'
	require 'mortals'
	require 'time'
	require 'motel'
	require 'ui'

  fontDefault=love.graphics.newFont("res/Arial-Unicode-Regular.ttf",15)
  fontSpooky=love.graphics.newFont("res/SpencersSpookyFontMONO.ttf",25)
  love.graphics.setFont(fontSpooky)
	fontCharWidth=13
	fontCharHeight=18


	newsFeedWidth=400
	checkNewsStories()

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

function love.update(dt)
	if(paused==false)then
		time=time+dt
		time2=time2+1
		u=getUpgrades()
		for k=1,#u do
			u[k]:update()
		end
		for k=1,#mortals do
			mortals[k]:update()
		end
		--if(everyMS(mortalInterval))then
		if(everyMS(10))then
			newMortal()
			mortalInterval=mortalInterval*0.9
			if(mortalInterval<mortalIntervalMin)then mortalInterval=mortalIntervalMin end
		end
	end
end;

function love.draw()
	love.graphics.setShader()
	--love.graphics.setCanvas(canvas)
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
	 avgRating=getAvgRating()
	 love.graphics.print("Avg Rating "..string.format("%.2f",avgRating),10,10)
	 love.graphics.setFont(fontDefault)
	 love.graphics.print(getRatingText(avgRating),220,7)
	 love.graphics.setFont(fontSpooky)

	 love.graphics.rectangle("line", newsFeedWidth+30, 10, window.w-newsFeedWidth-40, window.h/2-10)
 	 love.graphics.setColor(255,255,255,(55*(getHours(time2)/24)))
 	 love.graphics.rectangle("fill", newsFeedWidth+30, 10, window.w-newsFeedWidth-40, window.h/2-10)

	 local stencil = function()
	   love.graphics.rectangle("fill", newsFeedWidth+30, 60+fontCharHeight+5, window.w-newsFeedWidth-40, window.h/2-85)
	 end

	 love.graphics.stencil(stencil,"replace",1)
	 love.graphics.setStencilTest("greater", 0)
	 --love.window.showMessageBox("motel size", string.format("%d x %d",window.w-newsFeedWidth-40, window.h/2-10), "info", true)
	 --love.graphics.setColor(255, 0, 0, 255)

	 love.graphics.setColor(255, 255, 255, 255)
	 M.print(newsFeedWidth+100, 230+motelYOffset,5)


	 love.graphics.setColor(255, 255, 255, 150)
	 love.graphics.circle("fill", mouseX,mouseY,30, 40)
	 love.graphics.setColor(255, 255, 255, 255)


	  local stencil = function()
	    love.graphics.circle("fill", mouseX,mouseY,30, 40)
	  end

	  love.graphics.stencil(stencil,"replace",1)
	  love.graphics.setStencilTest("greater", 0)

		--stuff appear flashlight


	  love.graphics.stencil(stencil,"invert",1)

		--stuff disappear in flashlight


		love.graphics.setStencilTest()
	 --love.graphics.print("Time "..Inspect(time2), newsFeedWidth+40, 20)
	 for k=1,#mortals do
		 mortals[k]:draw(0,motelYOffset)
	 end
	 love.graphics.print(getDateTextFull(time2), newsFeedWidth+40, 20)
	 love.graphics.print(string.format("$%.2f",money), newsFeedWidth+40, 40)
	 love.graphics.print(string.format("Number of occupants %d of %d",howManyMortalsStaying(),getRoomNo()), newsFeedWidth+40, 60)



	love.graphics.rectangle("line", newsFeedWidth+30, 10, window.w-newsFeedWidth-40, window.h/2-10)
	 --love.graphics.setStencilTest()

	 love.graphics.rectangle("line", newsFeedWidth+30, window.h/2+10, window.w-newsFeedWidth-40, window.h/2-20)
	 drawUpgrades(newsFeedWidth+40,window.h/2+20,upgradesYOffset,window.w-newsFeedWidth-60, window.h/2-40,fontCharWidth,fontCharHeight)



	 love.graphics.setColor(255,255,255,255)
	 love.graphics.rectangle("line", window.w-65,15,50,50)
	 love.graphics.setFont(fontDefault)
	 love.graphics.print(pauseIcon,window.w-65+20,15+15)
	 love.graphics.setFont(fontSpooky)


	--love.graphics.setCanvas()

	--experimentShader:send("t",time)
	--love.graphics.setShader(experimentShader)
	--love.graphics.draw(canvas)
end

function love.mousepressed(x, y, button, isTouch)
	if(button==1)then
		checkUpgradesCol(newsFeedWidth+40,window.h/2+20,upgradesYOffset,window.w-newsFeedWidth-60, window.h/2-40,fontCharWidth,fontCharHeight,mouseX,mouseY)
		if(inBox(mouseX,mouseY,window.w-65,15,50,50))then
			if(paused==true)then paused=false pauseIcon="❚❚" else paused=true pauseIcon="▶" end
		end
	end
end

function love.mousemoved(x, y, dx, dy)
	mouseX=x
	mouseY=y
end

function love.keypressed(key, scancode, isrepeat)
	if(key=="r")then
		love.load()
	elseif(key=="q")then
		inspectPlayer=true
			m=Mortal()
			faults=getPossibleFaults()
			iLim=#faults
			if(#faults>3) then iLim=3 end
			for i=1,iLim do
				fault=choosePop(faults)
				--love.window.showMessageBox("fault", Inspect(fault), "info", true)
				m:addReviewFrag(ReviewFragment(fault.text,fault.rating,1))
			end
			m:leave()
	elseif(key=="w")then
		newMortal()
	elseif(key=="up")then
			checkScrollUp()
	elseif(key=="down")then
 		 checkScrollDown()
	end
end
function love.keyreleased(key)
	if(key=="q")then
		inspectPlayer=false
	end
end

function love.wheelmoved(x, y)
	 if y > 0 then
		 checkScrollUp()

	 elseif y < 0 then
		 checkScrollDown()

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
