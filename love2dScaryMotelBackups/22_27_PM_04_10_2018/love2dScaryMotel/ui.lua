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
  if(customerMenuId~=nil)then customersToAdmit[customerMenuId]:drawInfo(mouseX,mouseY,fW,fH) end
  love.graphics.setStencilTest()
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
  for r=1,math.floor(rating) do
    rateText=rateText.."★"
  end
  for r=1,5-math.floor(rating) do
    rateText=rateText.."☆"
  end
  return rateText
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
NewsStory=Class{
  init=function(self,title,body,newsFeedAmount)
    self.title=title
    self.body=body
    self.date=time2
    self.newsFeedAmount=newsFeedAmount
  end;
  getDateText=function(self)
    return string.format(self.date/100).."s"
  end;
  print=function(self,fW,fH,x,y,w)
    love.graphics.rectangle("fill", x+10, y+10, reviewPicWidth, reviewPicHeight)
    h=drawTextInBox(self.title,fW,fH,x+reviewPicWidth+20,y+10,w-reviewPicWidth-20)
    love.graphics.line(x+reviewPicWidth+20,y+30, w-10,y+30)
    h=drawTextInBox(self.body,fW,fH,x+reviewPicWidth+20,y+30,w-reviewPicWidth-20)
    love.graphics.print(getDateText(self.date),x+10,y+reviewPicHeight+40)
    if(h<reviewPicWidth+fH+50)then h=reviewPicWidth+fH+50 end
    love.graphics.rectangle("line", x, y, w, h+fH*2)
    return h
  end;
}
newNewsStory=function(title,body,newsFeedAmount)
  newsStoriesToAdd[#newsStoriesToAdd+1]=NewsStory(title,body,newsFeedAmount)
end

newNewsStory("New Motel Opens!","A new Motel has opened just off highway 5, the long-abandoned property was purchased by a plucky entrepreneur. Updates as business continues.",0)
