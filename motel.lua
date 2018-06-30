money=0
upgrades={}
Upgrade=Class{
  init=function(self,id,name,cost,rating,fragTable,newsFeedLenToAvailable,buyFunc,updateFunc)
    self.id=id
    self.name=name
    self.cost=cost
    self.rating=rating
    self.fragTable=fragTable
    self.newsFeedLenToAvailable=newsFeedLenToAvailable
    if(newsFeedLenToAvailable==0)then
      self.available=true
    else
      self.available=false
    end
    --love.window.showMessageBox(self.name, Inspect(buyFunc), "info", true)
    self.bought=false
    self.onBuy=buyFunc
    self.buyUpdate=updateFunc
  end;
  update=function(self)
    if(not self.bought)then
      if(not self.available)then
        if(self.newsFeedLenToAvailable~=nil and self.newsFeedLenToAvailable<#newsFeed)then
          self.available=true
        end
      end
    else
      if(self.buyUpdate~=nil)then
        self:buyUpdate()
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

      if(self.onBuy~=nil)then
        self:onBuy()
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
newUpgrade=function(name,cost,rating,fragTable,available)
  upgrades[#upgrades+1]=Upgrade(#upgrades+1,name,cost,rating,fragTable,available,nil,nil)
end

newUpgradeFuncs=function(name,cost,rating,fragTable,available,buyfunc,updatefunc)
  upgrades[#upgrades+1]=Upgrade(#upgrades+1,name,cost,rating,fragTable,available,buyfunc,updatefunc)
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
  for i=1,#upgrades do
    if(upgrades[i].bought==false and upgrades[i].available==true)then
      faultsToReturn[#faultsToReturn+1]={}
      faultsToReturn[#faultsToReturn].text=choose(upgrades[i].fragTable)
      faultsToReturn[#faultsToReturn].rating=upgrades[i].rating



    end
  end
  return faultsToReturn
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
newUpgrade("Clean",10,1,{"It was #veryDirty#"},0)
newUpgrade("Stairs",10,1,{"I couldn't get to my room"},0)
newUpgrade("Railing",10,1,{"There was no railing"},0)
newUpgrade("Sign",10,1,{"I had trouble finding the place"},0)
newUpgrade("Vending Machine",10,1,{"There was nothing to eat"},5)

T.addGrammarTable("strange",{"strange","weird","scary","worrying","concerning","suspicious","odd"})
T.addGrammarTable("noises",{"noises","sounds"})
T.addGrammarTable("strangeNoises",{"#strange# #noises#","#noises#"})

newUpgrade("Investigate noises",10,3,{"I couldn't sleep because of #strangeNoises#","I kept hearing #strangeNoises#","There were always #strangeNoises#","I kept being woken up by #strangeNoises#"},15)


newUpgrade("Install more lights",10,3,{"It was really dark","It was pitch black","I saw moving shadows"},20)


T.addGrammarTable("people",{"people","individuals","folk","peeps"})
T.addGrammarTable("groupOfPeople",{"bunch of #people#","group of #peopl#","collection of #people#","crowd"})
T.addGrammarTable("strangePeople",{"#strange# #people#","a #strange# #groupOfPeople#"})
newUpgrade("Investigate people hanging around",10,3,{"I saw #strangePeople#","#strangePeople# kept hanging around"},27)




T.addGrammarTable("symbols",{"symbols","icons","imagery","patterns","emblems"})
T.addGrammarTable("strangeSymbols",{"#strange# #symbols#","#symbols#"})
T.addGrammarTable("painted",{"painted","written","scrawled","scratched"})
T.addGrammarTable("partOfRoom",{"wall","bed","window","bathroom","mirror","floor"})
newUpgrade("Clean weird symbols",10,3,{"I had #strangeSymbols# #painted# on my #partOfRoom#"},36)


newUpgradeFuncs("Search pit",1000,3,{"There's a pit"},0,function(self) upgrades[getUpgradeByName("Appease the gods").id]:makeUnavailable() end,nil)
newUpgradeFuncs("Appease the gods",0,3,{"This pit calls to me"},0,function(self) upgrades[getUpgradeByName("Search pit").id]:makeUnavailable() end,nil)



--newUpgrade("Hire Shaman",10,2,{"I couldn't sleep because of #ghost#s"},25)
--love.window.showMessageBox("upgrades", Inspect(getPossibleFaults()), "info", true)
M={}
M.imgs={}
M.imgs.main=love.graphics.newImage("res/motel.png")
M.imgs.railing=love.graphics.newImage("res/railing.png")
M.imgs.stairs=love.graphics.newImage("res/stairs.png")
M.imgs.sign1=love.graphics.newImage("res/sign1.png")
M.imgs.sign2=love.graphics.newImage("res/sign2.png")
M.imgs.vendingMachine=love.graphics.newImage("res/vending_machine.png")
M.imgs.shadowPerson=love.graphics.newImage("res/shadowperson1.png")
M.print=function(x,y,w)
  love.graphics.draw(M.imgs.main,x,y,0,w,w)
  if(isBought("Stairs"))then
    love.graphics.draw(M.imgs.stairs,x,y,0,w,w)
  end
  if(isBought("Railing"))then
    love.graphics.draw(M.imgs.railing,x,y,0,w,w)
  end
  if(isBought("Vending Machine"))then
    love.graphics.draw(M.imgs.vendingMachine,x,y,0,w,w)
  end
  if(isBought("Sign"))then
    if(math.random()>0.9)then
      love.graphics.draw(M.imgs.sign2,x,y,0,w,w)
    else
      love.graphics.draw(M.imgs.sign1,x,y,0,w,w)
    end
  end
end
