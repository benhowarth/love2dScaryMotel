--money=0
money=100000
problems={}
Problem=Class{
  init=function(self,id,name,active,newsFeedLenToAvailable,updateMS,preFixUpdate,preFixDraw,preFixFragTable,preFixRating,postFixUpdate,postFixDraw,postFixFragTable,postFixRating)
    self.id=id
    self.name=name
    self.updateMS=updateMS
    self.active=active
    self.newsFeedLenToAvailable=newsFeedLenToAvailable
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
      if(self.newsFeedLenToAvailable~=nil and self.newsFeedLenToAvailable<#newsFeed)then
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
    self.newsFeedLenToAvailable=nil
  end;
  draw=function(self,x,y,w)
    if(self.fixed==true and self.postFixDraw~=nil)then
      self:postFixDraw(x,y,w)
    elseif(self.preFixDraw~=nil)then
      self:preFixDraw(x,y,w)
    end
  end;
}
newProblem=function(name,active,newsFeedLenToAvailable,updateMS,preFixUpdate,preFixDraw,preFixFragTable,preFixRating,postFixUpdate,postFixDraw,postFixFragTable,postFixRating)
  problems[#problems+1]=Problem(#problems+1,name,active,newsFeedLenToAvailable,updateMS,preFixUpdate,preFixDraw,preFixFragTable,preFixRating,postFixUpdate,postFixDraw,postFixFragTable,postFixRating)
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
    if(problem[i].active==true)then
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
  init=function(self,id,name,cost,newsFeedLenToAvailable,problemsItFixes,problemsItCauses,buyFunc)
    self.id=id
    self.name=name
    self.cost=cost
    self.newsFeedLenToAvailable=newsFeedLenToAvailable
    if(newsFeedLenToAvailable==0)then
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
        if(self.newsFeedLenToAvailable~=nil and self.newsFeedLenToAvailable<#newsFeed)then
          self.available=true
        end
      end
    end
  end;
  makeUnavailable=function(self)
    self.available=false
    self.newsFeedLenToAvailable=nil
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
newUpgrade=function(name,cost,newsFeedLenToAvailable,problemsItFixes,problemsItCauses)
  upgrades[#upgrades+1]=Upgrade(#upgrades+1,name,cost,newsFeedLenToAvailable,problemsItFixes,problemsItCauses)
end
newUpgradeSpecial=function(name,cost,newsFeedLenToAvailable,problemsItFixes,problemsItCauses,buyFunc)
  upgrades[#upgrades+1]=Upgrade(#upgrades+1,name,cost,newsFeedLenToAvailable,problemsItFixes,problemsItCauses,buyFunc)
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
getPossibleFaults=function()
  faultsToReturn={}
  for i=1,#problems do
    if(problems[i].fixed==false and problems[i].active==true)then
      if(problems[i].preFixFragTable~=nil)then
        faultsToReturn[#faultsToReturn+1]={}
        faultsToReturn[#faultsToReturn].text=choose(problems[i].preFixFragTable)
        faultsToReturn[#faultsToReturn].rating=problems[i].preFixRating
      end



    end
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
  return getUpgradeByName(name).bought==true
end


T.addGrammarTable("very",{"very","extremely"})
T.addGrammarTable("dirty",{"dirty","filthy"})
T.addGrammarTable("veryDirty",{"#dirty#","#very# #dirty#"})

--Problem
--(name,active,updateMS,preFixUpdate,preFixDraw,preFixFragTable,preFixRating,postFixUpdate,postFixDraw,postFixFragTable,postFixRating)
--upgrade
--(name,cost,newsFeedLenToAvailable,problemsItFixes,problemsItCauses)



newProblem("No Sign",true,nil,100,nil,nil,{"I had trouble finding the place"},1,nil,
function(self,x,y,w)
  if(math.random()>0.9)then
    love.graphics.draw(M.imgs.sign2,x-100,y-(floors[1].height*(#floors-1))-(w*7),0,w,w)
  else
    love.graphics.draw(M.imgs.sign1,x-100,y-(floors[1].height*(#floors-1))-(w*7),0,w,w)
  end
end,{"It had a sign"},3)
newUpgrade("Sign",10,0,{"No Sign"},nil)

newProblem("No Vending Machine",true,nil,100,nil,nil,{"There was nothing to eat"},1,nil,function(self,x,y,w) love.graphics.draw(M.imgs.vendingMachine,x,y,0,w,w,M.imgs.vendingMachine:getWidth()/2,M.imgs.vendingMachine:getHeight()/2) end,{"It had a vending machine"},3)
newUpgrade("Vending Machine",10,0,{"No Vending Machine"},nil)
--newUpgrade("Vending Machine",10,1,{"There was nothing to eat"},5)



T.addGrammarTable("strange",{"strange","weird","scary","worrying","concerning","suspicious","odd"})
T.addGrammarTable("noises",{"noises","sounds"})
T.addGrammarTable("strangeNoises",{"#strange# #noises#","#noises#"})

--newUpgrade("Investigate noises",10,3,{"I couldn't sleep because of #strangeNoises#","I kept hearing #strangeNoises#","There were always #strangeNoises#","I kept being woken up by #strangeNoises#"},15)

newProblem("Noises",false,3,100,nil,nil,{"I couldn't sleep because of #strangeNoises#","I kept hearing #strangeNoises#","There were always #strangeNoises#","I kept being woken up by #strangeNoises#"},1,nil,nil,{"It was peaceful"},4)
newUpgrade("Investigate Noises",10,3,{"Noises"},nil)

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



--newUpgrade("Hire Shaman",10,2,{"I couldn't sleep because of #ghost#s"},25)
--love.window.showMessageBox("upgrades", Inspect(getPossibleFaults()), "info", true)
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
M.imgs.shadowPerson=love.graphics.newImage("res/shadowperson1.png")
M.roofBottomWidthExtra=20
M.roofBottomHeight=20
M.roofTopHeight=10
M.print=function(x,y,w)
  --love.graphics.draw(M.imgs.main,x,y,0,w,w)
  love.graphics.setColor(0, 0, 0, 255)
  love.graphics.rectangle("fill",x-100,y+floors[1].height-floors[1].lineWidth*2,window.w/2,floors[1].height)
  love.graphics.setColor(255, 255, 255, 255)
  for f=1,#floors do
    --floors[f]:print(x,y-((f-1)*w*M.imgs.floor:getHeight()),w)
    floors[f]:print(x,y-((f-1)*w*10)-(f*floors[f].lineWidth*2),w)
  end
  love.graphics.rectangle("fill",x-M.roofBottomWidthExtra/2,y-((#floors-1)*w*10)-(#floors*floors[#floors].lineWidth*2)-M.roofBottomHeight,floors[#floors].width+M.roofBottomWidthExtra,M.roofBottomHeight)
  love.graphics.rectangle("fill",x,y-((#floors-1)*w*10)-(#floors*floors[#floors].lineWidth*2)-M.roofBottomHeight-M.roofTopHeight,floors[#floors].width,M.roofTopHeight)
  drawProblems(x+130,y-10,w)
end

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
  print=function(self,x,y,w)
    --print bg
    --love.graphics.draw(M.imgs.floor,x,y,0,w,w)
    love.graphics.setLineWidth(self.lineWidth)

    love.graphics.rectangle("line", x, y, self.width, self.height)
    love.graphics.setColor(0,0,0,255)
    love.graphics.rectangle("fill", x, y, self.width, self.height)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(255,255,255,255)
    for r=1,#self.rooms do
      --self.rooms[r]:print(x+((r-1)*w*M.imgs.room:getWidth()),y,w)
      self.rooms[r]:print(x,y,w)
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
  if(curFloor==1 or curFloor==0)then
    return true
  else
    return false
  end
end

newFloor(4)

addFloor=function(cost,roomNo)
  local floorNo=#floors
  newProblem(string.format("Dirty F%d",#floors),true,nil,100,nil,nil,{"It was #veryDirty#"},2,nil,nil,{"It was clean"},4)
  newUpgrade(string.format("Clean F%d",#floors),10,0,{string.format("Dirty F%d",#floors)},nil)
  if(#floors>=2)then
    newProblem(string.format("No Stairs F%d",#floors),true,nil,100,nil,nil,{"I couldn't get to my room"},1,nil,function(self,x,y,w) local curFloorY=y-((floors[floorNo].height-2)*(floorNo-2)) love.graphics.draw(M.imgs.stairs,x,curFloorY,0,w,w,M.imgs.stairs:getWidth()/2,M.imgs.stairs:getHeight()/2) end,{"It had stairs"},3)
    newUpgrade(string.format("Stairs to F%d",#floors),10,0,{string.format("Dirty F%d",#floors)},nil)

    newProblem(string.format("No Railing F%d",#floors),true,nil,100,nil,nil,{"There was no railing"},1,nil,function(self,x,y,w) local curFloorY=y-((floors[floorNo].height-2)*(floorNo-2)) love.graphics.draw(M.imgs.railing,x,curFloorY,0,w,w,M.imgs.railing:getWidth()/2,M.imgs.railing:getHeight()/2) end,{"The railing was nice"},3)
    newUpgrade(string.format("Railing F%d",#floors),10,0,{string.format("No Railing F%d",#floors)},nil)
  end

  newUpgradeSpecial(string.format("Build Floor %d",#floors+1),cost,0,nil,nil,function() newFloor(roomNo) addFloor(cost*5,roomNo) end)
end
addFloor(20,4)
--love.window.showMessageBox("floor", Inspect(floors), "info", true)
