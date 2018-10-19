money=0
money=100000


M={}
M.imgs={}
M.imgs.main=love.graphics.newImage("res/motel.png")
--M.imgs.floor=love.graphics.newImage("res/floor.png")
M.imgs.door=love.graphics.newImage("res/door.png")
roomWidth=10
roomHeight=15
M.imgs.railing=love.graphics.newImage("res/railing.png")
M.imgs.stairs=love.graphics.newImage("res/stairs.png")
M.imgs.sign1=love.graphics.newImage("res/sign1.png")
M.imgs.sign2=love.graphics.newImage("res/sign2.png")
M.imgs.vendingMachine=love.graphics.newImage("res/vending_machine.png")
M.imgs.vendingMachine2=love.graphics.newImage("res/vending_machine2.png")
M.imgs.shadowPerson=love.graphics.newImage("res/shadowperson1.png")
M.imgs.cat=love.graphics.newImage("res/cat.png")
M.imgs.cat2=love.graphics.newImage("res/cat2.png")
M.imgs.cat3=love.graphics.newImage("res/cat3.png")
M.imgs.hotdogcart=love.graphics.newImage("res/hotdogcart.png")
M.imgs.statue=love.graphics.newImage("res/statue.png")
M.imgs.statueGlow=love.graphics.newImage("res/statueGlow.png")
M.roofBottomWidthExtra=20
M.roofBottomHeight=20
M.roofTopHeight=10
M.print=function(x,y,w,fW,fH)
  --love.graphics.draw(M.imgs.main,x,y,0,w,w)

  love.graphics.setColor(0, 0, 0, 255)
  --print black ground
  floorY=y+floors[1].height-floors[1].lineWidth*2
  floorX=x
  --love.graphics.rectangle("fill",x-100,y+floors[1].height-floors[1].lineWidth*2,window.w+100,floors[1].height)
  love.graphics.rectangle("fill",x-motelXOffset,y+floors[1].height-floors[1].lineWidth*2,window.w+100,window.h/2)
  love.graphics.setColor(255, 255, 255, 255)
  for f=1,#floors do
    --floors[f]:print(x,y-((f-1)*w*M.imgs.floor:getHeight()),w)
    floors[f]:print(x,y-((f-1)*w*10)-(f*floors[f].lineWidth*2),w,fW,fH)
  end
  love.graphics.rectangle("fill",x-M.roofBottomWidthExtra/2,y-((#floors-1)*w*10)-(#floors*floors[#floors].lineWidth*2)-M.roofBottomHeight,floors[#floors].width+M.roofBottomWidthExtra,M.roofBottomHeight)
  love.graphics.rectangle("fill",x,y-((#floors-1)*w*10)-(#floors*floors[#floors].lineWidth*2)-M.roofBottomHeight-M.roofTopHeight,floors[#floors].width,M.roofTopHeight)
  drawProblems(x+130,y-10,w)
end

problems={}
Problem=Class{
  init=function(self,id,name,floor,active,availableFunc,updateMS,preFixUpdate,preFixDraw,preFixFragTable,preFixRating,postFixUpdate,postFixDraw,postFixFragTable,postFixRating)
    self.id=id
    self.name=name
    self.updateMS=updateMS
    self.active=active
    self.floor=floor
    self.availableFunc=availableFunc
    self.fixed=false
    self.preFixUpdate=preFixUpdate
    self.preFixDraw=preFixDraw
    self.preFixFragTable=preFixFragTable
    self.preFixRating=preFixRating
    self.postFixUpdate=postFixUpdate
    self.postFixDraw=postFixDraw
    self.postFixRating=postFixRating
  end;
  update=function(self)
    if(not self.active)then
      if(self.availableFunc~=nil and self:availableFunc()==true)then
        self.active=true
      end
    else
      if(everyMS(self.updateMS))then
        if(self.fixed==true and self.postFixUpdate~=nil)then
          self:postFixUpdate()
        elseif(self.preFixUpdate~=nil)then
          self:preFixUpdate()
        end
      end
    end
  end;
  makeUnavailable=function(self)
    self.available=false
  end;
  draw=function(self,x,y,w)
    if(self.fixed==true and self.postFixDraw~=nil)then
      self:postFixDraw(x,y,w)
    elseif(self.preFixDraw~=nil)then
      self:preFixDraw(x,y,w)
    end
  end;
}
newProblem=function(name,floor,active,availableFunc,updateMS,preFixUpdate,preFixDraw,preFixFragTable,preFixRating,postFixUpdate,postFixDraw,postFixFragTable,postFixRating)
  problems[#problems+1]=Problem(#problems+1,name,floor,active,availableFunc,updateMS,preFixUpdate,preFixDraw,preFixFragTable,preFixRating,postFixUpdate,postFixDraw,postFixFragTable,postFixRating)
end

getProblemByName=function(name)
  for i=1,#problems do
    if(problems[i].name==name)then return problems[i] end
  end
end
isFixed=function(name)
  return getUpgradeByName(name).fixed==true
end
updateProblems=function()
  for i=1,#problems do
    if(problems[i].active==true)then
      problems[i]:update()
    end
  end
end
drawProblems=function(x,y,w)
  for i=1,#problems do
    if(problems[i].active==true)then
      problems[i]:draw(x,y,w)
    end
  end
end



upgrades={}
Upgrade=Class{
  init=function(self,id,name,floor,cost,availableFunc,problemsItFixes,problemsItCauses,buyFunc)
    self.id=id
    self.name=name
    self.floor=floor
    self.cost=cost
    self.availableFunc=availableFunc
    if(availableFunc==nil)then
      self.available=true
    else
      self.available=false
    end
    --love.window.showMessageBox(self.name, Inspect(buyFunc), "info", true)
    self.bought=false
    self.problemsItFixes=problemsItFixes
    self.problemsItCauses=problemsItCauses
    self.buyFunc=buyFunc
  end;
  update=function(self)
    if(not self.bought)then
      if(not self.available)then
        if(self.availableFunc~=nil and self:availableFunc()==true)then
          self.available=true
        end
      end
    end
  end;
  makeUnavailable=function(self)
    self.available=false
  end;
  buy=function(self)
    if(money>=self.cost)then
      money=money-self.cost
      self.bought=true

      if(self.problemsItFixes~=nil)then
        for j=1,#self.problemsItFixes do
          problems[getProblemByName(self.problemsItFixes[j]).id].fixed=true
        end
      end
      if(self.problemsItCauses~=nil)then
        for j=1,#self.problemsItCauses do
          problems[getProblemByName(self.problemsItCauses[j]).id].active=true
        end
      end

      if(self.buyFunc~=nil)then
        self:buyFunc()
      end

    end
  end;
  print=function(self,fW,fH,x,y,w)
    if(self.cost>money)then love.graphics.setColor(125, 125, 125, 255)
    else love.graphics.setColor(255, 255, 255, 255) end
    h=drawTextInBox(string.format("%s ($%d)",self.name,self.cost),fW,fH,x,y,w)
    love.graphics.rectangle("line", x, y, w, h)
    return h
  end;
}
newUpgrade=function(name,floor,cost,availableFunc,problemsItFixes,problemsItCauses)
  upgrades[#upgrades+1]=Upgrade(#upgrades+1,name,floor,cost,availableFunc,problemsItFixes,problemsItCauses)
end
newUpgradeSpecial=function(name,floor,cost,availableFunc,problemsItFixes,problemsItCauses,buyFunc)
  upgrades[#upgrades+1]=Upgrade(#upgrades+1,name,floor,cost,availableFunc,problemsItFixes,problemsItCauses,buyFunc)
end

getUpgrades=function()
  return upgrades
end
getAvailableUpgrades=function()
  upgradesToReturn={}
  for i=1,#upgrades do
    if(upgrades[i].available==true and upgrades[i].bought==false)then
      upgradesToReturn[#upgradesToReturn+1]=upgrades[i]
    end
  end
  return upgradesToReturn
end
getPossibleFaults=function(floor)
  faultsToReturn={}
  for i=1,#problems do
    if(problems[i].fixed==false and (problems[i].availableFunc==nil or problems[i]:availableFunc()==true) and problems[i].active==true and (problems[i].floor==nil or problems[i].floor==floor))then
      if(problems[i].preFixFragTable~=nil)then
        faultsToReturn[#faultsToReturn+1]={}
        faultsToReturn[#faultsToReturn].text=choose(problems[i].preFixFragTable)
        faultsToReturn[#faultsToReturn].rating=problems[i].preFixRating
      end



    end
  end
  --check noise
  noiseSum=0
  for i=1,#floors[floor].rooms do
    if(floors[floor].rooms[i].currentMortal~=nil)then
      noiseSum=noiseSum+mortals[floors[floor].rooms[i].currentMortal].stats["noise"]
    end
  end
  if(noiseSum>6)then
    faultsToReturn[#faultsToReturn].text=T.parse("It was noisey")
    faultsToReturn[#faultsToReturn].rating=math.floor(1-(noiseSum/#floors[floor].rooms*3))*5
  end

  --check cleanliness
  local cleanScore=floors[floor].cleanScore
  if(cleanScore>0.9)then
      faultsToReturn[#faultsToReturn].text=T.parse("It was very clean")
      faultsToReturn[#faultsToReturn].rating=5
  elseif(cleanScore>0.8)then
      faultsToReturn[#faultsToReturn].text=T.parse("It was pretty clean")
      faultsToReturn[#faultsToReturn].rating=4
  elseif(cleanScore>=0)then
        faultsToReturn[#faultsToReturn].text=T.parse("It was very dirty")
        faultsToReturn[#faultsToReturn].rating=2
  elseif(cleanScore<0)then
        faultsToReturn[#faultsToReturn].text=T.parse("It was very bloody")
        faultsToReturn[#faultsToReturn].rating=1
  end
  return faultsToReturn
end
getPossibleCompliments=function()
  ComplimentsToReturn={}
  for i=1,#problems do
    if(problems[i].fixed==true and problems[i].active==true)then
      if(problems[i].postFixFragTable~=nil)then
        ComplimentsToReturn[#faultsToReturn+1]={}
        ComplimentsToReturn[#faultsToReturn].text=choose(problems[i].postFixFragTable)
        ComplimentsToReturn[#faultsToReturn].rating=problems[i].postFixRating
      end



    end
  end
  return ComplimentsToReturn
end

getUpgradeByName=function(name)
  for i=1,#upgrades do
    if(upgrades[i].name==name)then return upgrades[i] end
  end
end
isBought=function(name)
  if(getUpgradeByName(name)==nil)then love.window.showMessageBox("nil isbought", Inspect(name), "info", true) end
  return getUpgradeByName(name).bought==true
end




T.addGrammarTable("very",{"very","extremely","unbelievably","incredibly","super"})
T.addGrammarTable("dirty",{"dirty","filthy","gross"})
T.addGrammarTable("veryDirty",{"#dirty#","#very# #dirty#"})

--Problem
--(name,floor,active,availableFunc,updateMS,preFixUpdate,preFixDraw,preFixFragTable,preFixRating,postFixUpdate,postFixDraw,postFixFragTable,postFixRating)
--upgrade
--(name,floor,cost,availableFunc,problemsItFixes,problemsItCauses)



newProblem("No Sign",nil,true,nil,100,nil,nil,{"I had trouble finding the place"},1,nil,
function(self,x,y,w)
  if(math.random()>0.9)then
    love.graphics.draw(M.imgs.sign2,x,y-((floors[1].height+(-1*floors[1].lineWidth))*(#floors-1))+50,0,w,w,M.imgs.sign2:getWidth()/2,M.imgs.sign2:getHeight()/2)
  else
    love.graphics.draw(M.imgs.sign1,x,y-((floors[1].height+(-1*floors[1].lineWidth))*(#floors-1))+50,0,w,w,M.imgs.sign1:getWidth()/2,M.imgs.sign1:getHeight()/2)
  end
end,{"It had a sign"},3)
newUpgrade("Sign",nil,10,nil,{"No Sign"},nil)

vendingMachineTimerMax=400
vendingMachineTimer=vendingMachineTimerMax
newProblem("No Vending Machine",nil,true,nil,100,nil,nil,{"There was nothing to eat"},1,nil,function(self,x,y,w)
  if(vendingMachineTimer>0)then
    if(isBought("Bash Rats In Vending Machine")==false or  howManyMortalsStaying()>0)then
      vendingMachineTimer=vendingMachineTimer-1
    end
    love.graphics.draw(M.imgs.vendingMachine,x,y,0,w,w,M.imgs.vendingMachine:getWidth()/2,M.imgs.vendingMachine:getHeight()/2)
  else
    love.graphics.draw(M.imgs.vendingMachine2,x,y,0,w,w,M.imgs.vendingMachine:getWidth()/2,M.imgs.vendingMachine:getHeight()/2)
    love.graphics.rectangle("line",floorX+floors[1].width-10,floorY-50,50,70);
    if(inBox(mouseX,mouseY,floorX+floors[1].width-10,floorY-50,50,70) and love.mouse.isDown(1))then vendingMachineTimer=vendingMachineTimerMax end
  end
end,{"It had a vending machine"},3)


--did this function have something in?????
newProblem("No Hotdogs",nil,true,function() return isBought("Vending Machine") end,100,function(self,x,y,w)end,nil,{"There was only vending machine to eat"},3,nil,nil,{"It had delicious hotdogs"},4)
newUpgradeSpecial("Vending Machine",nil,10,nil,{"No Vending Machine"},{"No Hotdogs"},function()
  newNewsStory("Vending Machine","Got the new vending machine installed. You may have to restock every so often (watch out for rats, you're gonna get some rats). -"..getHelpInitial())
 end)
newUpgradeSpecial("Get More Stock For Vending Machine",nil,40,function() return isBought("Vending Machine") end,nil,nil,function()
  vendingMachineTimerMax=800
  newNewsStory("RE Vending Machine","Fixed a hole in the vending machine where the rats were getting in but they're stilling getting in. Might need a more permenant solution. -"..getHelpInitial())
end)
newUpgradeSpecial("Bash Rats In Vending Machine",nil,60,function() return isBought("Get More Stock For Vending Machine") end,nil,nil,function()
  vendingMachineTimerMax=1300
  newNewsStory("RE RE Vending Machine","Rats dead. All dead. Whole generations of those things have died at my hands. -"..getHelpInitial())
end)



T.addGrammarTable("strange",{"strange","weird","scary","worrying","concerning","suspicious","odd"})
T.addGrammarTable("noises",{"noises","sounds"})
T.addGrammarTable("strangeNoises",{"#strange# #noises#","#noises#"})

--newUpgrade("Investigate noises",10,3,{"I couldn't sleep because of #strangeNoises#","I kept hearing #strangeNoises#","There were always #strangeNoises#","I kept being woken up by #strangeNoises#"},15)

newProblem("Noises",nil,false,function() return #newsFeed>3 end,100,nil,nil,{"I couldn't sleep because of #strangeNoises#","I kept hearing #strangeNoises#","There were always #strangeNoises#","I kept being woken up by #strangeNoises#"},1,nil,nil,{"It was peaceful"},4)
newUpgrade("Investigate Noises",nil,10,function() return #newsFeed>3 end,{"Noises"},nil)

--newUpgrade("Install more lights",10,3,{"It was really dark","It was pitch black","I saw moving shadows"},20)


T.addGrammarTable("people",{"people","individuals","folk","peeps"})
T.addGrammarTable("groupOfPeople",{"bunch of #people#","group of #peopl#","collection of #people#","crowd"})
T.addGrammarTable("strangePeople",{"#strange# #people#","a #strange# #groupOfPeople#"})
--newUpgrade("Investigate people hanging around",10,3,{"I saw #strangePeople#","#strangePeople# kept hanging around"},27)




T.addGrammarTable("symbols",{"symbols","icons","imagery","patterns","emblems"})
T.addGrammarTable("strangeSymbols",{"#strange# #symbols#","#symbols#"})
T.addGrammarTable("painted",{"painted","written","scrawled","scratched"})
T.addGrammarTable("partOfRoom",{"wall","bed","window","bathroom","mirror","floor","nightstand"})
--newUpgrade("Clean weird symbols",10,3,{"I had #strangeSymbols# #painted# on my #partOfRoom#"},36)


--newUpgradeFuncs("Search pit",1000,3,{"There's a pit"},0,function(self) upgrades[getUpgradeByName("Appease the gods").id]:makeUnavailable() end,nil)
--newUpgradeFuncs("Appease the gods",0,3,{"This pit calls to me"},0,function(self) upgrades[getUpgradeByName("Search pit").id]:makeUnavailable() end,nil)

cats={}
Cat=Class{
  init=function(self,x,y)
    self.x=x
    self.y=y
  end;
  draw=function(self,x,y,w)
    if(evilPerc>0.7)then
      love.graphics.draw(M.imgs.cat3,self.x+x,self.y+y,0,w,w,M.imgs.cat:getWidth()/2,M.imgs.cat:getHeight()/2)
    elseif(evilPerc>0.5)then
      love.graphics.draw(M.imgs.cat2,self.x+x,self.y+y,0,w,w,M.imgs.cat:getWidth()/2,M.imgs.cat:getHeight()/2)
    else
      love.graphics.draw(M.imgs.cat,self.x+x,self.y+y,0,w,w,M.imgs.cat:getWidth()/2,M.imgs.cat:getHeight()/2)
    end
  end;
}
hotdogTop=math.ceil(math.random()*#mortalTop)
hotdogBottom=math.ceil(math.random()*#mortalBottom)
hotdogClosedTimer=0

newProblem("Cats",nil,false,function() return isBought("Vending Machine") and #newsFeed>5 end,100,
function(self)
  if(getNightTime() and #cats<10)then
    --if(math.floor(math.fmod(time2,dayLen/3))==0)then
      --cats[#cats+1]=Cat(math.random(0,50),math.random(0,50))
      --cats[#cats+1]=Cat(0,0)
      cats[#cats+1]=Cat(newsFeedWidth+math.random(motelXOffset-100,motelXOffset+600),floors[1].height+math.random(0,15))
      --love.window.showMessageBox("new cat"..Inspect(#cats), Inspect(cats), "info", true)
    --end
  end
  if(inBox(mouseX,mouseY,280+motelXOffset,120+floors[1].height+motelYOffset,100,100) and love.mouse.isDown(1) and hotdogClosedTimer==0) then
    cats={}
    evilPercAdd(0.001)
    hotdogClosedTimer=5
    hotdogTop=math.ceil(math.random()*#mortalTop)
    hotdogBottom=math.ceil(math.random()*#mortalBottom)
  end
  if(hotdogClosedTimer>0) then hotdogClosedTimer=hotdogClosedTimer-1 end
end,
function(self,x,y,w)
  --love.graphics.draw(M.imgs.cat,x,y,0,w,w,M.imgs.cat:getWidth()/2,M.imgs.cat:getHeight()/2)
    love.graphics.setColor(255, 0, 0, 255)
    --love.graphics.rectangle("line",x+motelXOffset-100,y+floors[1].height+motelYOffset,100,100)
    love.graphics.rectangle("line",280+motelXOffset,120+floors[1].height+motelYOffset,100,100)
    love.graphics.setColor(255, 255, 255, 255)
    if(hotdogClosedTimer==0)then
      love.graphics.draw(mortalBase, x-60-floors[1].width/2,y+floors[1].height-30, 0,5,5,5,5)
      love.graphics.draw(mortalTop[hotdogTop], x-60-floors[1].width/2,y+floors[1].height-30, 0,5,5,5,5)
      love.graphics.draw(mortalBottom[hotdogBottom], x-60-floors[1].width/2,y+floors[1].height-30, 0,5,5,5,5)
    end
    love.graphics.draw(M.imgs.hotdogcart,x-30-floors[1].width/2,y+floors[1].height,0,w/2,w/2,M.imgs.hotdogcart:getWidth(),M.imgs.hotdogcart:getHeight())
  for i=1,#cats do
    cats[i]:draw(x,y,w/2)
  end
end,{"I couldn't sleep because of cats"},1,nil,nil,{"There were no cats"},4)
newUpgradeSpecial("Hire hotdog cart",nil,10,function() return isBought("Vending Machine") and #newsFeed>5 end,{"No Hotdogs"},{"Cats"})


--statueTimer=30
statueTimer=1
--statueHelpTimer=50
statueHelpTimer=30
statueHelpCounter=0
newProblem("Mound",nil,false,function() return #newsFeed>4 end,100,nil,nil,{"I tripped over a mound in the parking lot"},2,nil,nil,{"The ground was smooth"},3)
newProblem("Statue",nil,false,function() return isBought("Vending Machine") and #newsFeed>5 end,100,

function(self)

  if(inBox(mouseX,mouseY,floorX+floors[1].width+100,floorY-100,100,100) and love.mouse.isDown(1) and statueTimer==0) then
    evilPercAdd(0.001)
    --statueTimer=20
    statueTimer=1
    cursorState="kill"
    --turn off threats
    statueHelpTimer=-1
    --love.window.showMessageBox("Kill", "message", "info", true)
  end
  if(statueHelpTimer==0)then
    if(statueHelpCounter<1)then
      newNewsStory("A helpful message!","That shiny new statue can be used to eradicate a bad review!")
    elseif(statueHelpCounter<2)then
      newNewsStory("A friendly reminder!","You seem to be having problems with your reviews, try removing a review with the statue!")
    elseif(statueHelpCounter<3)then
      newNewsStory("A firm reminder.","This wouldn't be going so badly if you'd have used the statue.")
    else
      newNewsStory("GIVE IN TO THE STATUE","SUBMIT TO THE STATUE")
    end
    statueHelpTimer=clamp(50-(30*statueHelpCounter/4),20,50)
    statueHelpCounter=statueHelpCounter+1
  end
  if(statueTimer>0) then statueTimer=statueTimer-1 end
  if(statueHelpTimer>0) then statueHelpTimer=statueHelpTimer-1 end
end,
function(self,x,y,w)
  --love.graphics.draw(M.imgs.cat,x,y,0,w,w,M.imgs.cat:getWidth()/2,M.imgs.cat:getHeight()/2)
    love.graphics.setColor(255, 0, 0, 255)
    love.graphics.rectangle("line", floorX+floors[1].width+100,floorY-100,100,100)
    love.graphics.setColor(255, 255, 255, 255)
    if(statueTimer>0)then
      love.graphics.draw(M.imgs.statue,x+30+floors[1].width,y+floors[1].height,0,w,w,M.imgs.statue:getWidth(),M.imgs.statue:getHeight())
    else
      love.graphics.draw(M.imgs.statueGlow,x+30+floors[1].width,y+floors[1].height,0,w,w,M.imgs.statueGlow:getWidth(),M.imgs.statueGlow:getHeight())
    end
end,{"There was a weird statue outside"},2,nil,nil,{"There was no weird statue outside"},1)
newUpgradeSpecial("Unearth mound",nil,10,function() return isBought("Vending Machine") and #newsFeed>5 end,{"Mound"},{"Statue"})



alphabet="abcdefghijklmnopqrstuvwxyz"
floors={}
Room=Class{
  init=function(self,id,x,y)
    self.id=id
    self.currentMortal=nil
    self.x=x
    self.y=y
  end;
  print=function(self,x,y,w)
    love.graphics.draw(M.imgs.door,x+self.x,y+self.y,0,w,w)
    if(inBox(mouseX,mouseY,x+self.x,y+self.y,35,50))then
      if(cursorState~="kill")then
        --if(stayPercentage>0)then
          roomMenuId=self.id
        --end
      else
        if(love.mouse.isDown(1) and self.currentMortal~=nil)then
          mortals[self.currentMortal]:goMissing()
          cursorState=nil
        end
      end
    end
    if(self.currentMortal~=nil)then
      stayPercentage=mortals[self.currentMortal].stayTimer/mortals[self.currentMortal].stay
      love.graphics.rectangle("line",x+self.x,y+self.y-10,35,6)
      love.graphics.rectangle("fill",x+self.x,y+self.y-10,35*stayPercentage,6)



      love.graphics.setColor(255,0,0,255)
      love.graphics.rectangle("line",x+self.x,y+self.y,35,50)
        love.graphics.setColor(255,255,255,255)



    end
  end;
  assignMortal=function(self,mortalId)
    if(self.currentMortal==nil)then
      self.currentMortal=mortalId
    end
  end;
  deassignMortal=function(self)
    if(self.currentMortal~=nil)then
      self.currentMortal=nil
    end
  end;
}
Floor=Class{
  init=function(self,id,roomNo)
    self.id=id
    self.rooms={}
    self.height=60
    self.width=250
    self.lineWidth=4
    if(roomNo~=nil)then
      self.bufferWidth=(self.width-((roomNo+1)*roomWidth))/(roomNo)
      self.bufferHeight=0
      if(self.height>self.bufferHeight)then
        self.bufferHeight=roomHeight
      end
      for r=1,roomNo do
        self:addRoom(-self.bufferWidth/2-roomWidth/2+((r-1)*roomWidth+ (self.bufferWidth*(r)) ),self.bufferHeight)
      end
      self.vacancy=true
    end
    self.cleanScore=1
  end;
  hasVacancy=function(self)
    for r=1,#self.rooms do
      if(self.rooms[r].currentMortal==nil)then
        return true
      end
    end
    return false
  end;
  getVacantRoom=function(self)
    for r=1,#self.rooms do
      if(self.rooms[r].currentMortal==nil)then
        return r
      end
    end
    return nil
  end;
  addRoom=function(self,x,y)
    self.rooms[#self.rooms+1]=Room(#self.rooms+1,x,y)
  end;
  makeDirtier=function(self,dirtScore)
    if(self.cleanScore>0)then
      self.cleanScore=self.cleanScore-dirtScore
      if(self.cleanScore<0)then self.cleanScore=0 end
    end
  end;
  makeBloody=function(self)
    self.cleanScore=-1
  end;
  makeClean=function(self)
    self.cleanScore=1
  end;
  getCleanString=function(self)
    if(self.cleanScore==1)then return "Floor very clean"
    elseif(self.cleanScore>0.7)then return "Floor quite clean"
    elseif(self.cleanScore>0.4)then return "Floor dirty"
    elseif(self.cleanScore>=0)then return "Floor very dirty"
    else return "Floor very bloody"
    end
  end;
  pickRoomGoMissing=function(self,murdererRoomId)
    local roomToMurder=murdererRoomId
    local roomToMurderOptions={}
    for p=1,#self.rooms do
      if(p~=murdererRoomId and self.rooms[p].currentMortal~=nil)then
        roomToMurderOptions[#roomToMurderOptions+1]=p
      end
    end
    if(#roomToMurderOptions>0)then
      roomToMurder=choose(roomToMurderOptions)
      --love.window.showMessageBox(Inspect(murdererRoomId).." to murder", Inspect(roomToMurder), "info", true)
      mortals[self.rooms[roomToMurder].currentMortal]:goMissing(true)
    else
      return false
    end
  end;
  print=function(self,x,y,w,fW,fH)
    --print bg
    --love.graphics.draw(M.imgs.floor,x,y,0,w,w)
    love.graphics.setLineWidth(self.lineWidth)

    love.graphics.rectangle("line", x, y, self.width, self.height)
    love.graphics.setColor(0,0,0,255)
    love.graphics.rectangle("fill", x, y, self.width, self.height)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(255,255,255,255)
    roomMenuId=nil
    for r=1,#self.rooms do
      --self.rooms[r]:print(x+((r-1)*w*M.imgs.room:getWidth()),y,w)
      self.rooms[r]:print(x,y,w)
    end

    --room menu showing current mortal etc
    local mX=love.mouse.getX()
    local mY=love.mouse.getY()
    if(roomMenuId~=nil)then
      if(self.rooms[roomMenuId].currentMortal~=nil)then
        local occupantInfo="arriving"
        if(mortals[self.rooms[roomMenuId].currentMortal].stayTimer/mortals[self.rooms[roomMenuId].currentMortal].stay>0)then
          occupantInfo="staying"
        end
        queueMenuBox({"Occupant ("..occupantInfo..") ",mortals[self.rooms[roomMenuId].currentMortal].name,mortals[self.rooms[roomMenuId].currentMortal].bio,unpack(mortals[self.rooms[roomMenuId].currentMortal]:getStats())},10,fW,fH,mX,mY,150)

      else
        --draw non occupy menu
        queueMenuBox({"No Occupant"},10,fW,fH,mX,mY,150)
      end

    else
      --if not hovering over room, check hovering over floor
      if(inBox(mX,mY,x,y,self.width,self.height))then
        queueMenuBox({"Floor info",self:getCleanString()},10,fW,fH,mX,mY,150)
      end
    end
  end;
}
newFloor=function(roomNo)
  floors[#floors+1]=Floor(#floors+1,roomNo)

end
getAvailableFloor=function()
  for f=1,#floors do
    if(floors[f]:hasVacancy()==true)then
      return floors[f].id
    end
  end
end
getRoomNo=function()
  totalRooms=0
  for f=1,#floors do
    totalRooms=totalRooms+#floors[f].rooms
  end
  return totalRooms
end
isRoomAccessible=function(floor)
  local curFloor=floor-1
  while(curFloor>1 and isBought("Stairs to F"..Inspect(curFloor)))do
    curFloor=curFloor-1
  end
  if(curFloor==1)then
    if(isBought("Stairs to F2"))then
      return true
    else
      return false
    end
  elseif(curFloor==0)then
    return true
  else
    return false
  end
end

newFloor(4)

addFloor=function(cost,roomNo)
  local floorNo=#floors
  newProblem(string.format("Old F%d",#floors),floorNo,true,nil,100,nil,nil,{"It was drab"},2,nil,nil,{"It was renovated"},4)
  newUpgrade(string.format("Renovate F%d",#floors),floorNo,10,nil,{string.format("Old F%d",#floors)},nil)
  if(#floors>=2)then
    newProblem(string.format("No Stairs F%d",#floors),floorNo,true,nil,100,nil,nil,{"I couldn't get to my room"},1,nil,function(self,x,y,w) local xDir=1 local xBuffer=0 local curFloorY=y-((floors[floorNo].height-2)*(floorNo-2)) if(math.fmod(floorNo,2)~=0)then xDir=-1 xBuffer=-M.imgs.stairs:getWidth()*w end love.graphics.line(x-floors[1].width/2-6,curFloorY,x-floors[1].width/2-6-M.imgs.stairs:getWidth()*w,curFloorY) love.graphics.draw(M.imgs.stairs,x-floors[1].width/2-6+xBuffer,curFloorY-6,0,w*xDir,w,M.imgs.stairs:getWidth()) end,{"It had stairs"},3)
    newUpgrade(string.format("Stairs to F%d",#floors),floorNo,10,nil,{string.format("No Stairs F%d",#floors)},nil)

    newProblem(string.format("No Railing F%d",#floors),floorNo,true,nil,100,nil,nil,{"There was no railing"},1,nil,function(self,x,y,w) local curFloorY=y-((floors[floorNo].height-2)*(floorNo-2)) love.graphics.draw(M.imgs.railing,x,curFloorY,0,w,w,M.imgs.railing:getWidth()/2,M.imgs.railing:getHeight()/2) end,{"The railing was nice"},3)
    newUpgrade(string.format("Railing F%d",#floors),floorNo,10,nil,{string.format("No Railing F%d",#floors)},nil)
  end

  newUpgradeSpecial(string.format("Build Floor %d",#floors+1),nil,cost,nil,nil,nil,function() newFloor(roomNo) addFloor(cost*5,roomNo) end)
end
addFloor(20,4)
--love.window.showMessageBox("floor", Inspect(floors), "info", true)
