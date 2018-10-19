require 'mortalGrammars'
mortals={}
missingMortalsNo=0
ReviewFragment=Class{
  init=function(self,text,rating,weight)
    self.text=text
    self.rating=rating
    self.weight=weight
  end;
}
reviewPicWidth=60
reviewPicHeight=60
Review=Class{
  init=function(self,text,rating,mortalId)
    self.text=text
    self.rating=rating
    self.mortalId=mortalId
    self.date=time2
    self.redacted=false
  end;
  print=function(self,fW,fH,x,y,w)



    h=drawTextInBox(self.text,fW,fH,x+reviewPicWidth+20,y+10,w-reviewPicWidth-20)
    if(h<reviewPicWidth+fH+50)then h=reviewPicWidth+fH+50 end

    h=h+fH*3

    love.graphics.setColor(20,20,20,255)
    love.graphics.rectangle("fill", x, y, w, h)

    love.graphics.setColor(255,255,255,255)

    if(not self.redacted)then
      love.graphics.draw(mortalBase, x+15, y+15, 0,5,5)
      love.graphics.draw(mortalTop[mortals[self.mortalId].top], x+15, y+15, 0,5,5)
      love.graphics.draw(mortalBottom[mortals[self.mortalId].bottom], x+15, y+15, 0,5,5)
    else
      love.graphics.setFont(fontDefault)
      love.graphics.print("FILE\nNOT\nFOUND",x+10,y+10)
      love.graphics.setFont(fontSpooky)
    end

    love.graphics.rectangle("line", x+10, y+10, reviewPicWidth, reviewPicHeight)

    drawTextInBox(self.text,fW,fH,x+reviewPicWidth+20,y+10,w-reviewPicWidth-20)




    love.graphics.setColor(255,255,255,255)
    love.graphics.setFont(fontDefault)
    love.graphics.print(getRatingText(self.rating),x+10,y+reviewPicHeight+20)
    love.graphics.setFont(fontSpooky)
    love.graphics.print(getDateText(self.date),x+10,y+reviewPicHeight+40)


    love.graphics.print(string.format("-%s (%d.%d)",mortals[self.mortalId].name,mortals[self.mortalId].floorId,mortals[self.mortalId].roomId),x+reviewPicWidth+20,y+h-fH)

    if(self.redacted)then
      love.graphics.setColor(0,0,0,255)
      local linesNo=(h-fH*3)/fH
      --black out review text
      for li=0,linesNo do
        love.graphics.rectangle("fill",x+reviewPicWidth+20,y+10+(li*fH),w-reviewPicWidth-20,fH)
      end

      --black out name
      love.graphics.rectangle("fill",x+reviewPicWidth+20,y+h-fH+2,w-reviewPicWidth-20,fH-4)
      --black out rating
      love.graphics.rectangle("fill",x+10,y+reviewPicHeight+20+2,reviewPicWidth,15)
      --black out date
      love.graphics.rectangle("fill",x+10,y+reviewPicHeight+40+2,reviewPicWidth,fH-4)
    end

    love.graphics.rectangle("line", x, y, w, h)

    --draw bio/check for kill
    local mX=love.mouse.getX()
    local mY=love.mouse.getY()
    if(inBox(mX,mY,x+10,y+10,reviewPicWidth, reviewPicHeight))then
      local socialWidth=fW*(#mortals[self.mortalId].username+2)
      local bioH=drawTextInBox(mortals[self.mortalId].bio,fW,fH,mX,mY+fH+2,socialWidth)
      love.graphics.setColor(255,255,255, 255)
      love.graphics.rectangle("line",mX,mY,socialWidth+fW,bioH+fH+2)
      love.graphics.setColor(0,0,0, 255)
      love.graphics.rectangle("fill", mX,mY,socialWidth+fW,bioH+fH+2)
      love.graphics.setColor(255,255,255, 255)




      if((not self.redacted))then
        love.graphics.setFont(fontDefault)
        love.graphics.print("@",mX+2,mY)
        love.graphics.setFont(fontSpooky)
        love.graphics.print(mortals[self.mortalId].username,mX+20,mY+2)
        drawTextInBox(mortals[self.mortalId].bio,fW,fH,mX,mY+fH+2,socialWidth)
        if(love.mouse.isDown(1) and cursorState=="kill")then
          self.redacted=true
          cursorState=nil
          mortals[self.mortalId]:goMissing()
        end
      else
        love.graphics.print("Error",mX+2,mY+2)
        drawTextInBox("404 Not Found",fW,fH,mX,mY+fH+2,150)
      end


    end
    --end of bio draw



    return h
  end;
}
mortalBase=love.graphics.newImage("res/mortal.png")
mortalTop={}
mortalTop[1]=love.graphics.newImage("res/mortalTop1.png")
mortalTop[2]=love.graphics.newImage("res/mortalTop2.png")
mortalTop[3]=love.graphics.newImage("res/mortalTop3.png")
mortalBase=love.graphics.newImage("res/mortal.png")
mortalBottom={}
mortalBottom[1]=love.graphics.newImage("res/mortalBottom1.png")
mortalBottom[2]=love.graphics.newImage("res/mortalBottom2.png")
mortalBottom[3]=love.graphics.newImage("res/mortalBottom3.png")
mortalBottom[4]=love.graphics.newImage("res/mortalBottom4.png")
mortalBottom[5]=love.graphics.newImage("res/mortalBottom5.png")
Mortal=Class{
  init=function(self,id,mortalType)
    self.id=id
    self.firstName=T.parse("#firstName#")
    self.lastName=T.parse("#lastName#")
    self.name=self.firstName.." "..self.lastName
    self.username=self.name..math.floor(math.random(1,99))
    if(mortalType~=nil)then
      self.type=mortalType
    else
      self.type="normal"
    end
    if(self.type=="cop")then
      self.bio=T.parse("#copBio#")
    elseif(self.type=="murderer")then
      self.bio=T.parse("#creepyBio#")
    else
      self.bio=T.parse("#bio#")
    end
    self.reviewFrags={}
    self.reviewString=""
    self.rating=0
    self.x=newsFeedWidth+10
    --self.y=270
    self.y=260
    self.state="WAITING"
    self.direction=1
    self.stay=(math.random()*300)+100
    self.stayTimer=0
    self.floorId=nil
    self.roomId=nil
    --love.window.showMessageBox(self.name, string.format("Floor %d\nRoom %d",self.floorId,self.roomId), "info", true)
    self.top=math.ceil(math.random()*#mortalTop)
    self.bottom=math.ceil(math.random()*#mortalBottom)
  end;
  update=function(self)
    --entering
    if(self.state=="ENTERING")then
      if(isRoomAccessible(self.floorId)) then
        --love.window.showMessageBox(self.name, Inspect(self.y).." vs "..Inspect(self.target.y).."\n"..Inspect(within(self.y,self.target.y,70)), "info", true)
        if(within(self.x,self.target.x,20) and within(self.y,self.target.y,20))then
        --if(self.x>newsFeedWidth+80)then
          self.state="STAYING"
        elseif(within(self.x,newsFeedWidth+motelXOffset,10) and not(within(self.y,self.target.y,20)))then
          self.y=self.y-3
          love.window.showMessageBox(self.name, "climns"..Inspect({within(self.x,newsFeedWidth+motelXOffset,10),not(within(self.y,self.target.y,20))}), "info", true)
        else
          self.x=self.x+(self.direction*3)
        end
      else
        --love.window.showMessageBox(self.name, "Room inaccessible", "info", true)
      end
    --staying
    elseif(self.state=="STAYING")then
      self.stayTimer=self.stayTimer+1
      if(self.stayTimer>self.stay)then
        --self.x=window.w-100
        floors[self.floorId].rooms[self.roomId]:deassignMortal()
        self.state="LEAVING"
      end
    --leaving
    elseif(self.state=="LEAVING")then
      self.x=self.x+4
      if(self.x>window.w)then
        self:leave()
      end
    end
  end;
  draw=function(self,xOffset,yOffset)
    if(self.state~="LEFT" and self.state~="STAYING" and self.state~="MISSING" and self.state~="WAITING")then
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.draw(mortalBase, self.x+xOffset, self.y+yOffset, 0,5,5,5,5)
      love.graphics.draw(mortalTop[self.top], self.x+xOffset, self.y+yOffset, 0,5,5,5,5)
      love.graphics.draw(mortalBottom[self.bottom], self.x+xOffset, self.y+yOffset, 0,5,5,5,5)
      --love.graphics.rectangle("fill", self.x, self.y, 30, 30)
      love.graphics.print(string.format("%d.%d",self.floorId,self.roomId), self.x+xOffset, self.y+yOffset)
    end
  end;
  drawInfo=function(self,x,y,fW,fH)
    local drawMenuNameH=drawTextInBox(self.name,fW,fH,x,y,150)
    local drawMenuInfoH=drawTextInBox(self.bio,fW,fH,x,y+10+drawMenuNameH,150)
    local drawMenuH=drawMenuNameH+10+drawMenuInfoH+20
    love.graphics.setColor(0,0,0,255)
    love.graphics.rectangle("fill", mouseX,mouseY,150,drawMenuH)
    love.graphics.setColor(255,255,255,255)
    love.graphics.rectangle("line", mouseX,mouseY,150,drawMenuH)
    drawTextInBox(self.name,fW,fH,x,y,150)
    drawTextInBox(self.bio,fW,fH,x,y+10+drawMenuNameH,150)
  end;
  printCustomer=function(self,fW,fH,x,y,w)
    local h=drawTextInBox(self.name,fW,fH,x,y,w)
    love.graphics.rectangle("line", x, y, w, h)
    return h
  end;
  getFinalReview=function(self,fragNumber)
    table.sort(self.reviewFrags,function(a,b) return a.weight>b.weight end)
    if(#self.reviewFrags<fragNumber)then fragNumber=#self.reviewFrags end
    if(#self.reviewFrags~=0)then
      self.rating=0
      for i=1,fragNumber do
        T.setVar("frag"..Inspect(i),self.reviewFrags[i].text)
        --self.reviewString=self.reviewString.." "..self.reviewFrags[i].text
        --love.window.showMessageBox("rating", Inspect(self).."\n"..Inspect(self.reviewFrags[i]), "info", true)
        self.rating=((self.rating*(i-1))+self.reviewFrags[i].rating)/i
      end
      --love.window.showMessageBox(Inspect(fragNumber), Inspect(T.variables), "info", true)
      self.reviewString=T.parse("#review"..Inspect(fragNumber).."#")
      self.rating=math.floor(self.rating)
      for i=1,fragNumber do
        T.clearVar("frag"..Inspect(i))
      end

    else
      self.reviewString="#good#"
      self.rating=5
    end
    return Review(T.parse(self.reviewString),self.rating,self.id)
  end;
  addReviewFrag=function(self,frag)
      self.reviewFrags[#self.reviewFrags+1]=frag
  end;
  findRoom=function(self,floorId)
    self.floorId=floorId
    self.roomId=floors[floorId]:getVacantRoom()
    if(self.roomId~=nil)then
      floors[self.floorId].rooms[self.roomId]:assignMortal(self.id)
      self.target={x=floors[self.floorId].rooms[self.roomId].x+(newsFeedWidth+motelXOffset)+roomWidth/2,y=floors[self.floorId].rooms[self.roomId].y+230+motelYOffset-((floorId-1)*floors[1].height)}
    end
  end;
  leave=function(self)
    self.state="LEFT"

    faults=getPossibleFaults(self.floorId)
    iLim=#faults
    if(#faults>3) then iLim=3 end
    for i=1,iLim do
      fault=choosePop(faults)
      --love.window.showMessageBox("fault", Inspect(fault), "info", true)
      self:addReviewFrag(ReviewFragment(fault.text,fault.rating,1))
    end
    money=money+self.stay*0.05
  	addToNewsFeed(self:getFinalReview(3))
  end;
  goMissing=function(self)

    --if not left
    if(self.state=="STAYING")then
      money=money+self.stay*0.45
    	addToNewsFeed(Review(T.parse("THE BEAST CONSUMES"),5,self.id))
    end

    self.state="MISSING"
    missingMortalsNo=missingMortalsNo+1
    evilPercAdd(0.002)
    self.x=window.w+100

    floors[self.floorId].rooms[self.roomId]:deassignMortal()
  end;
}

--mortalTypes={{"normal",0.9},{"murderer",0.06},{"cop",0.04}}
mortalTypes={{"normal",0.33},{"murderer",0.33},{"cop",0.34}}
decideMortalType=function()
  local mortalProbR=love.math.random()
  local sum=0
  local typeChosen=0
  while(mortalProbR>sum and typeChosen<#mortalTypes)do
    typeChosen=typeChosen+1
    sum=sum+mortalTypes[typeChosen][2]
  end
  --love.window.showMessageBox(mortalTypes[typeChosen][1]..Inspect(mortalProbR),Inspect(mortals), "info", true)
  return mortalTypes[typeChosen][1]
end;

newMortal=function(mortalType)
  if(#getCustomers()<customerLim)then
    if(mortalType==nil)then mortalType=decideMortalType() end
    mortals[#mortals+1]=Mortal(#mortals+1,mortalType)
  end
end;

getCustomers=function()
  local availableCustomers={}
  for i=1,#mortals do
    if(mortals[i].state=="WAITING")then
      availableCustomers[#availableCustomers+1]=mortals[i]
    end
  end
  return availableCustomers
end;

activateCustomer=function(cn)
  if(getAvailableFloor()~=nil and floors[getAvailableFloor()]:getVacantRoom()~=nil)then
    --love.window.showMessageBox("new mort", Inspect(customer), "info", true)
    --mortals[#mortals+1]=customer
    --mortals[#mortals].state="ENTERING"
    mortals[cn]:findRoom(getAvailableFloor())
    mortals[cn].state="ENTERING"
    --love.window.showMessageBox("new mort2", Inspect(mortals), "info", true)
  end
end;

howManyMortalsStaying=function()
  mortalNum=0
  for h=1,#mortals do
    if(mortals[h].state=="STAYING")then mortalNum=mortalNum+1 end
  end
  return mortalNum
end
