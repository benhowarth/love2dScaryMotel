newsFeed={}
function addToNewsFeed(thing)
  newsFeed[#newsFeed+1]=thing
  checkNewsStories()
end

--amount of news to show at once
newsFeedClip=15
function drawNewsFeed(x,y,yOffset,w,h,fW,fH)
  local stencil = function()
    love.graphics.rectangle("fill", x,y,w,h)
  end

  love.graphics.stencil(stencil,"replace",1)
  love.graphics.setStencilTest("greater", 0)
  newsFeedHeight=0
  --make it unpack properly
  local newsFeedNew={unpack(newsFeed,clamp(#newsFeed-newsFeedClip,1,#newsFeed),#newsFeed)}
  for n=1,#newsFeedNew do
    newsFeedHeight=newsFeedHeight+newsFeedNew[#newsFeedNew+1-n]:print(fW,fH,x,y+newsFeedHeight+yOffset,w)+fH*2
  end

  love.graphics.setStencilTest()



end

function getHelpInitial()
  return "C"
end
function drawUpgrades(x,y,yOffset,w,h,fW,fH)
  local stencil = function()
    love.graphics.rectangle("fill", x,y,w,h)
  end

  love.graphics.stencil(stencil,"replace",1)
  love.graphics.setStencilTest("greater", 0)
  upgradesHeight=0
  upgradesToBuy={}
  upgradesToBuy=getAvailableUpgrades()
  for n=1,#upgradesToBuy do
    upgradesHeight=upgradesHeight+upgradesToBuy[n]:print(fW,fH,x,y+upgradesHeight+yOffset,w)+10
  end

  love.graphics.setColor(255,255,255)
  love.graphics.setStencilTest()
end

function checkUpgradesCol(x,y,yOffset,w,h,fW,fH,x1,y1)
  upgradesHeight=0
  upgradesToBuy={}
  upgradesToBuy=getAvailableUpgrades()
  if(inBox(x1,y1,x,y,w,h))then
    for n=1,#upgradesToBuy do
      h=upgradesToBuy[n]:print(fW,fH,x,y+upgradesHeight,w)
      if(inBox(x1,y1,x+10,y+upgradesHeight+yOffset,w,h))then
        upgrades[upgradesToBuy[n].id]:buy()
      end
      upgradesHeight=upgradesHeight+h+10
    end
  end
end

function drawCustomers(x,y,yOffset,w,h,fW,fH)
  local stencil = function()
    love.graphics.rectangle("fill", x,y,w,h)
  end

  love.graphics.stencil(stencil,"replace",1)
  love.graphics.setStencilTest("greater", 0)
  local customerMenuId=nil
  customersHeight=0
  customersToAdmit=getCustomers()
  for n=1,#customersToAdmit do
    if(inBox(mouseX,mouseY,x+10,y+customersHeight+yOffset,w,h))then
      --love.window.showMessageBox("yo", Inspect(customersToAdmit[n]), "info", true)
      customerMenuId=n
    end
    customersHeight=customersHeight+customersToAdmit[n]:printCustomer(fW,fH,x,y+customersHeight+yOffset,w)+10
  end
  love.graphics.setStencilTest()
  if(customerMenuId~=nil)then customersToAdmit[customerMenuId]:drawInfo(mouseX,mouseY,fW,fH) end
end

function checkCustomersCol(x,y,yOffset,w,h,fW,fH,x1,y1)
  customersHeight=0
  customersToAdmit=getCustomers()
  if(inBox(x1,y1,x,y,w,h))then
    for n=1,#customersToAdmit do
      local h=customersToAdmit[n]:printCustomer(fW,fH,x,y+customersHeight+yOffset,w)
      if(inBox(x1,y1,x+10,y+customersHeight+yOffset,w,h))then
        --love.window.showMessageBox("yo", Inspect(customersToAdmit[n]), "info", true)
        activateCustomer(customersToAdmit[n].id)
      end
      customersHeight=customersHeight+h+10
    end
  end
end

function getAvgRating()
  rating=5
  for n=1,#newsFeed do
    if(newsFeed[n].rating~=nil)then
      rating=((rating*(n-1))+newsFeed[n].rating)/n
    end
  end
  return rating
end


getRatingText=function(rating)

  rateText=""
  if(rating~=nil)then
    for r=1,math.floor(rating) do
      rateText=rateText.."★"
    end
    for r=1,5-math.floor(rating) do
      rateText=rateText.."☆"
    end
  end
  return rateText
end;

function drawClock(x,y,rad,hour,min,printAMPM)
  if(printAMPM==true)then
    love.graphics.setColor(255, 255, 255)
    local AMPM="AM"
    if(math.fmod(hour,24)>=12)then AMPM="PM" end
    love.graphics.print(AMPM,x-14,y+rad/2)
  end
  love.graphics.setLineWidth(5)
  local hourAng=-((hour/12)*2*math.pi)-math.pi
  local minAng=-((min/60)*2*math.pi)-math.pi
  love.graphics.setColor(255,0,0,255)
  love.graphics.line(x, y, x+rad*math.sin(minAng),y+rad*math.cos(minAng))
  love.graphics.setColor(255,255,255)
  love.graphics.line(x, y, x+rad*0.5*math.sin(hourAng),y+rad*0.5*math.cos(hourAng))
  love.graphics.circle("line",x,y,rad)
  love.graphics.setLineWidth(1)
  love.graphics.setColor(255,255,255)
end;

newsStoriesToAdd={}
checkNewsStories=function()
  for l=1,#newsStoriesToAdd do
    if(#newsFeed<=newsStoriesToAdd[l].newsFeedAmount)then
      addToNewsFeed(newsStoriesToAdd[l])
      newsStoriesToAdd[l]=nil
    end
  end
end
newsFeedSpeed=0.05
NewsStory=Class{
  init=function(self,title,body,newsFeedAmount)
    self.title=title
    self.body=body
    self.date=time2
    self.newsFeedAmount=newsFeedAmount
    self.heightMult=0
  end;
  getDateText=function(self)
    return string.format(self.date/100).."s"
  end;
  print=function(self,fW,fH,x,y,w)

    if(self.heightMult<1)then self.heightMult=self.heightMult+newsFeedSpeed end
    h=drawTextInBox(self.title,fW,fH,x+reviewPicWidth+20,y+10,w-reviewPicWidth-20,nil,true)
    h=drawTextInBox(self.body,fW,fH,x+reviewPicWidth+20,y+30,w-reviewPicWidth-20,nil,true)
    if(h<reviewPicWidth+fH+50)then h=reviewPicWidth+fH+50 end

    --actually draw
    h=h*self.heightMult

    local stencil = function()
      love.graphics.rectangle("fill", x-2,y-2,w+4,h+4)
    end

    love.graphics.stencil(stencil,"replace",1)
    love.graphics.setStencilTest("greater", 0)

    love.graphics.setColor(0,0,0,255)
    love.graphics.rectangle("fill", x, y, w, h+fH*2)
    love.graphics.setColor(255,255,255,255)


    love.graphics.rectangle("fill", x+10, y+10, reviewPicWidth, reviewPicHeight)
    drawTextInBox(self.title,fW,fH,x+reviewPicWidth+20,y+10,w-reviewPicWidth-20,h)
    love.graphics.line(x+reviewPicWidth+20,y+30, w-10,y+30)
    love.graphics.print(getDateText(self.date),x+10,y+reviewPicHeight+40)
    drawTextInBox(self.body,fW,fH,x+reviewPicWidth+20,y+30,w-reviewPicWidth-20,h)
    love.graphics.print(getDateText(self.date),x+10,y+reviewPicHeight+40)


    love.graphics.rectangle("line", x, y, w, h+fH*2)

    love.graphics.setStencilTest()
    return h+35
  end;
}
newNewsStory=function(title,body,newsFeedAmount)
  if(newsFeedAmount~=nil)then
    newsStoriesToAdd[#newsStoriesToAdd+1]=NewsStory(title,body,newsFeedAmount)
  else
    addToNewsFeed(NewsStory(title,body,nil))
  end
end

newNewsStory("New Motel Opens!","A new Motel has opened just off highway 5, the long-abandoned property was purchased by a plucky entrepreneur. Updates as business continues.")

newNewsStory("RE Motel Purchase","Hi, I'm the help around here. Give me a shout if you need anything, especially if you want to try to improve this place. -"..getHelpInitial())
addToNewsFeed(Review("This is a review for the motel, customers will give you feedback and a rating, try to keep your rating up. Let's get you started with a nice 5 stars. -"..getHelpInitial(),5,nil))
