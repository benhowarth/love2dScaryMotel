require 'mortalGrammars'
mortals={}
missingMortalsNo=0
lastInvestigationProgress=0
investigationProgress=0

function getInvestigationNewsStory()
  if(investigationProgress==1 and lastInvestigationProgress~=1)then
    --end game
    newNewsStory("GAME OVER","It looks like it's game over for the seedy happenings at the motel that's been under investigation.")
  elseif(investigationProgress>0.7 and lastInvestigationProgress<=0.7)then
    --newsStory
    newNewsStory("Motel 'top priority'","Looks like the investigation into the new motel has gotten the attention of the chief of police.")
  elseif(investigationProgress>0.5 and lastInvestigationProgress<=0.5)then
    --newsStory
    newNewsStory("Crime motel?","Police announce full investigation of new motel.")
    newDraggable("police letter",0,0,80,100,"policeLetter","A letter regarding the ongoing investigation about the motel. This doesn't look good.")
  elseif(investigationProgress>0.3 and lastInvestigationProgress<=0.3)then
    --newsStory
    newNewsStory("More motel cops","Police presence near the new motel has increased.")
  elseif(investigationProgress>0.1 and lastInvestigationProgress<=0.1)then
    --newsStory
    newNewsStory("Police seen at motel","Cops have been 'snooping around' new motel.")
  end
end

function addInvestigationProgress(n)
  lastInvestigationProgress=investigationProgress
  if(investigationProgress+n>1)then
    investigationProgress=1
    getInvestigationNewsStory()
    if(not gameEnd)then
      gameOver()
    end
  else
    investigationProgress=investigationProgress+n
    getInvestigationNewsStory()
  end
end

ReviewFragment=Class{
  init=function(self,text,rating,weight,problemToNotify)
    self.text=text
    self.rating=rating
    self.weight=weight
    self.problemToNotify=problemToNotify
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
    self.heightMult=0
    self.read=false
  end;
  print=function(self,fW,fH,x,y,w)


    if(self.heightMult<1)then self.heightMult=self.heightMult+newsFeedSpeed end
    h=drawTextInBox(self.text,fW,fH,x+reviewPicWidth+20,y+10,w-reviewPicWidth-20,nil,true)
    if(h<reviewPicWidth+fH+50)then h=reviewPicWidth+fH+50 end

    h=h+fH*3
    h=h*self.heightMult


      local stencil = function()
        love.graphics.rectangle("fill", x-2,y-2,w+4,h+4)
      end

      love.graphics.stencil(stencil,"replace",1)
      love.graphics.setStencilTest("greater", 0)

    --love.graphics.setColor(20,20,20,255)
    love.graphics.setColor(0,0,0,255)
    love.graphics.rectangle("fill", x, y, w, h)

    love.graphics.setColor(255,255,255,255)
    love.graphics.setColor(255,255,255,255)

    if(not self.redacted and self.mortalId~=nil)then
      love.graphics.draw(mortalBase, x+15, y+15, 0,5,5)
      love.graphics.draw(mortalTop[mortals[self.mortalId].top], x+15, y+15, 0,5,5)
      love.graphics.draw(mortalBottom[mortals[self.mortalId].bottom], x+15, y+15, 0,5,5)
    else
      love.graphics.setFont(fontDefault)
      love.graphics.print("FILE\nNOT\nFOUND",x+10,y+10)
      love.graphics.setFont(fontSpooky)
    end


    love.graphics.rectangle("line", x+10, y+10, reviewPicWidth, reviewPicHeight)

    drawTextInBox(self.text,fW,fH,x+reviewPicWidth+20,y+10,w-reviewPicWidth-20,h-5)




    love.graphics.setColor(255,255,255,255)
    love.graphics.setFont(fontDefault)
    love.graphics.print(getRatingText(self.rating),x+10,y+reviewPicHeight+20)
    love.graphics.setFont(fontSpooky)
    love.graphics.print(getDateText(self.date),x+10,y+reviewPicHeight+40)

    if(self.mortalId~=nil)then
      --love.graphics.print(string.format("-%s (Room %d)",mortals[self.mortalId].name,(mortals[self.mortalId].floorId*100)+mortals[self.mortalId].roomId),x+reviewPicWidth+20,y+h-fH)
      love.graphics.print(string.format("%s (Room %d)",mortals[self.mortalId].name,(mortals[self.mortalId].floorId*100)+mortals[self.mortalId].roomId),x+5,y+h-fH)
    end
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

        love.graphics.setColor(255,255,255,255)
    end


    if(self.read)then
      love.graphics.setColor(255,255,255,255)
    else
      love.graphics.setColor(255,0,0,255)
    end

    love.graphics.rectangle("line", x, y, w, h)

    --draw bio/check for kill
    local mX=love.mouse.getX()
    local mY=love.mouse.getY()

    --if in review pic
      --if not redacted
        --if killcursor
          --if mouse down
              --kill
        --draw non redacted bio
      --else
        --draw redacted bio
    if(inBox(mX,mY,x,y,w,h) and self.heightMult>=1)then
      if(not self.read)then self.read=true end




      if((not self.redacted) and self.mortalId~=nil)then

        if(love.mouse.isDown(1) and cursorState=="kill")then
          self.redacted=true
          self.rating=nil
          cursorState=nil
          mortals[self.mortalId]:goMissing(nil)
        end
        --love.graphics.setFont(fontDefault)
        --love.graphics.print("@",mX+2,mY)

        love.graphics.setFont(fontSpooky)
        drawMenuBox({mortals[self.mortalId].firstName.." "..mortals[self.mortalId].lastName,mortals[self.mortalId].bio,unpack(mortals[self.mortalId]:getStats())},10,fW,fH,mX,mY,150)

      else
        drawMenuBox({"Error","404 Not Found"},10,fW,fH,mX,mY,150)
      end


    end
    --end of bio draw

    love.graphics.setStencilTest()



    return h
  end;
}
mortalBase=love.graphics.newImage("res/mortal.png")
mortalCatEyes=love.graphics.newImage("res/mortalCatEyes.png")
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

mortalPayMultiplier=0.005

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


    self.stats={}
    self.stats["noise"]=math.floor(math.random(1,3))
    self.stats["clean"]=math.floor(math.random(1,3))
    self.stats["pay"]=math.floor(math.random(1,3))

    if(self.type=="cop")then
      self.bio=T.parse("#copBio#")
      self.helloString=T.parse("#copHello#")
    elseif(self.type=="murderer")then
      self.bio=T.parse("#creepyBio#")
      self.helloString=T.parse("#creepyHello#")
      self.stats["pay"]=3
    else
      self.bio=T.parse("#bio#")
      self.helloString=T.parse("#hello#")
    end



    self.reviewFragsNeg={}
    self.reviewFragsPos={}
    self.reviewString=""
    self.rating=0
    self.x=newsFeedWidth+10
    --self.y=270
    self.y=motelGroundY
    self.state="WAITING"
    self.direction=1
    --self.stay=(math.random()*300)+100
    --self.stay=(math.random()*800)+200
    --self.stay=(math.random()*1600)+500
    self.stay=(math.random()*dayLen*1.5)+dayLen
    if(self.type=="murderer")then self.stay=self.stay*1.5 end
    self.stayTimer=0
    self.floorId=nil
    self.roomId=nil
    --love.window.showMessageBox(self.name, string.format("Floor %d\nRoom %d",self.floorId,self.roomId), "info", true)
    self.top=math.ceil(math.random()*#mortalTop)
    self.bottom=math.ceil(math.random()*#mortalBottom)

    self.possessed=false
  end;
  update=function(self)
    --msg("y offset",Inspect(motelYOffset))
    --entering
    if(self.state=="ENTERING")then
      if(isRoomAccessible(self.floorId)) then
        self.target={x=floors[self.floorId].rooms[self.roomId].x+(newsFeedWidth+motelXOffset)+roomWidth*4,y=floors[self.floorId].rooms[self.roomId].y+230+motelYOffset-((self.floorId-1)*floors[1].height)}

        --love.window.showMessageBox(self.name, Inspect(self.y).." vs "..Inspect(self.target.y).."\n"..Inspect(within(self.y,self.target.y,70)), "info", true)
        if(within(self.x,self.target.x,20) and within(self.y+motelYOffset,self.target.y,20))then
        --if(self.x>newsFeedWidth+80)then
          self.state="STAYING"
        elseif(within(self.x,newsFeedWidth+motelXOffset,10) and not(within(self.y+motelYOffset,self.target.y,20)))then
        --elseif(within(self.x,newsFeedWidth+motelXOffset,50) and not(within(self.y,self.target.y,20)))then
          self.y=self.y-3
          --love.window.showMessageBox(self.name, "climns"..Inspect({within(self.x,newsFeedWidth+motelXOffset,50),not(within(self.y,self.target.y,20))}).."\n"..Inspect(self.target).." real:"..Inspect(self.x)..", "..Inspect(self.y), "info", true)
        else
          self.x=self.x+(self.direction*3)
        end
      else
        --love.window.showMessageBox(self.name, "Room inaccessible", "info", true)
      end
    --staying
    elseif(self.state=="STAYING")then
      self.stayTimer=self.stayTimer+1

      if(self.type=="cop")then
        --investigate

      elseif(self.type=="murderer")then
        --murder a person?
        if(everyMS(100) and math.random()>0.8)then
          floors[self.floorId]:pickRoomGoMissing(self.roomId)
        end
      end

      local temp=getTemperature()
      if(math.random()>0.9)then
        if(temp>80)then
          self:goMissing("boil")
        elseif(temp<-80)then
          self:goMissing("freeze")
        end
      end

      if(self.stayTimer>self.stay)then
        --self.x=window.w-100
        floors[self.floorId].rooms[self.roomId]:deassignMortal()
        self.state="LEAVING"
        self:leave()
      end
    --leaving
    elseif(self.state=="LEAVING")then
      if(self.y<motelGroundY)then self.y=self.y*1.05 end
      self.x=self.x+4
      if(self.x>window.w)then
        self.state="LEFT"
      end
    end
  end;
  draw=function(self,xOffset,yOffset)
    if(self.state~="LEFT" and (self.state~="STAYING" or floors[self.floorId].rooms[self.roomId].open==1) and self.state~="MISSING" and self.state~="WAITING")then
      local scale=5
      local yAdditionalOffset=0
      --if(floors[self.floorId].rooms[self.roomId].open==1 and self.state=="STAYING")then scale=3 end
      if(self.state=="STAYING")then
        if(not self.possessed)then
          queueMenuBox({self.helloString},0,fontCharWidth,fontCharHeight, self.x+xOffset+30, self.y+yOffset-30,200)
          love.graphics.setColor(255, 255, 255, 255)
        else
          scale=2.5
          yAdditionalOffset=-10
          love.graphics.setColor(150, 150, 150, 255)
        end
      end
      love.graphics.draw(mortalBase, self.x+xOffset, self.y+yOffset+yAdditionalOffset, 0,scale,scale,scale,scale)
      love.graphics.draw(mortalTop[self.top], self.x+xOffset, self.y+yOffset+yAdditionalOffset, 0,scale,scale,scale,scale)
      love.graphics.draw(mortalBottom[self.bottom], self.x+xOffset, self.y+yOffset+yAdditionalOffset, 0,scale,scale,scale,scale)
      if(self.possessed)then
        love.graphics.draw(mortalCatEyes, self.x+xOffset, self.y+yOffset+yAdditionalOffset, 0,scale,scale,scale,scale)
      end
      if(self.state=="LEAVING")then
        --love.graphics.rectangle("fill", self.x, self.y, 30, 30)
        for c,cat in pairs(cats)do
          --love.graphics.rectangle("line",motelXOffset+(floors[1].width*2)+cat.x+30,cat.y+(floors[1].height*2)+60,30,45)
          if(cat.active and math.random()>0.985)then
            if(inBox(self.x,self.y,motelXOffset+(floors[1].width*2)+cat.x+30,cat.y+(floors[1].height*2)+60,30,45))then
              self:goMissing()
              --msg(self.name..Inspect(cat.id),"missing")
            end
          end
        end
      end
      --love.graphics.print(string.format("%d.%d",self.floorId,self.roomId), self.x+xOffset, self.y+yOffset)
    end
      --if(self.target~=nil)then
        --love.graphics.setColor(255,0,0,255)
        --love.graphics.circle("fill",self.target.x,self.target.y,10)
        --love.graphics.setColor(255,255,255,255)
        --love.graphics.circle("fill",self.x,self.y+motelYOffset,10)
      --end
  end;
  getStatsString=function(self)
    local statsString="\n "
    for k,v in pairs(self.stats) do
      statsString=statsString..k.." "..v.."\n "
    end
    return statsString
  end;
  getStats=function(self)
    local stats={}
    for k,v in pairs(self.stats) do
      stats[#stats+1]=k.." "..v
    end
    return stats
  end;
  getStatsBars=function(self)
    local stats={}
    for k,v in pairs(self.stats) do
      stats[#stats+1]={v,3,k}
    end
    return stats
  end;
  getCurrentStayString=function(self)
    local stayString=string.format("%.1f hr",24*((self.stay-self.stayTimer)/dayLen))
    if(((self.stay-self.stayTimer)/dayLen)>=1)then stayString=string.format("%.1f dy",((self.stay-self.stayTimer)/dayLen)) end
    return stayString
  end;
  getStayString=function(self)
    local stayString=string.format("%.2f hrs ($%.2f)",24*(self.stay/dayLen),self.stay*mortalPayMultiplier*self.stats["pay"])
    if((self.stay/dayLen)>=1)then stayString=string.format("%.2f days ($%.2f)",(self.stay/dayLen),self.stay*mortalPayMultiplier*self.stats["pay"]) end
    return stayString
  end;
  drawInfo=function(self,x,y,fW,fH)
    --local drawMenuNameH=drawTextInBox(self.name,fW,fH,x,y,150)
    --local drawMenuInfoH=drawTextInBox(self.bio,fW,fH,x,y+10+drawMenuNameH,150)
    --local statsString=self:getStatsString()
    local stayString=self:getStayString()
    --local drawMenuStats=drawTextInBox(statsString..stayString,fW,fH,x,y+10+drawMenuNameH+10+drawMenuInfoH,150)+40+20
    --local drawMenuH=drawMenuNameH+10+drawMenuStats+10+drawMenuInfoH+20
    local bars=self:getStatsBars()
    drawMenuH=drawTextInBoxTable({self.name,self.bio,bars[1],bars[2],bars[3],stayString},10,fW,fH,mouseX,mouseY,150)
    love.graphics.setColor(0,0,0,255)
    love.graphics.rectangle("fill", mouseX,mouseY,150,drawMenuH)
    love.graphics.setColor(255,255,255,255)
    love.graphics.rectangle("line", mouseX,mouseY,150,drawMenuH)
    --drawTextInBox(self.name,fW,fH,x,y,150)
    --drawTextInBox(self.bio,fW,fH,x,y+10+drawMenuNameH,150)
    --drawTextInBox(statsString..stayString,fW,fH,x,y+10+drawMenuNameH+10+drawMenuInfoH,150)
    drawTextInBoxTable({self.name,self.bio,bars[1],bars[2],bars[3],stayString},10,fW,fH,mouseX,mouseY,150)
  end;
  printCustomer=function(self,fW,fH,x,y,w)
    local h=drawTextInBox(self.name,fW,fH,x,y,w)
    love.graphics.rectangle("line", x, y, w, h)
    return h
  end;
  getFinalReview=function(self,fragNumber)
    table.sort(self.reviewFragsNeg,function(a,b) return a.weight>b.weight end)
    table.sort(self.reviewFragsPos,function(a,b) return a.weight>b.weight end)

    --love.window.showMessageBox("neg", Inspect(self.reviewFragsNeg), "info", true)
    --love.window.showMessageBox("pos", Inspect(self.reviewFragsPos), "info", true)
    --decide on how many pos and how many neg
    local negNum=clamp(#self.reviewFragsNeg,0,fragNumber)
    local posNum=clamp(#self.reviewFragsPos,0,fragNumber)
    while(negNum+posNum>fragNumber)do
      if(negNum-1>0 and love.math.random(1,10)>3)then
        negNum=negNum-1
      elseif(posNum-1>0)then
        posNum=posNum-1
      end
    end


    --love.window.showMessageBox("neg vs pos number", "fragNumber: "..fragNumber.."\nneg: "..negNum.."\npos: "..posNum.."\nneg frags:"..#self.reviewFragsNeg.."\npos frags:"..#self.reviewFragsPos, "info", true)
    local ratingsString="\n\n\n"
    if(self.possessed)then
      self.reviewString="#possessedGood#"
      self.rating=5
    elseif(#self.reviewFragsNeg~=0 or #self.reviewFragsPos~=0)then
      self.rating=0
      for i=1,negNum do
        --msg("negNum"..i,self.reviewFragsNeg[i].text)
        if(self.reviewFragsNeg[i].problemToNotify~=nil) then
          --msg(problems[self.reviewFragsNeg[i].problemToNotify].name.." appeared",Inspect(problems[self.reviewFragsNeg[i].problemToNotify]))
          problems[self.reviewFragsNeg[i].problemToNotify].appeared=true
        end
        T.setVar("negfrag"..Inspect(i),self.reviewFragsNeg[i].text)
        self.rating=self.rating+self.reviewFragsNeg[i].rating
        ratingsString=ratingsString..self.reviewFragsNeg[i].rating.."\n"
      end
      for i=1,posNum do
        --msg("posNum"..i,self.reviewFragsPos[i].text)
        T.setVar("posfrag"..Inspect(i),self.reviewFragsPos[i].text)
        self.rating=self.rating+self.reviewFragsPos[i].rating
        ratingsString=ratingsString..self.reviewFragsPos[i].rating.."\n"
      end
      self.rating=self.rating/(negNum+posNum)
      --msg("final rating",self.rating..ratingsString)
      --msg("vars",Inspect(T.variables))
      --love.window.showMessageBox(Inspect(fragNumber), Inspect(T.variables), "info", true)
      self.reviewString=T.parse("#review"..Inspect(negNum).."n"..Inspect(posNum).."p#")
      --msg("#review"..Inspect(negNum).."n"..Inspect(posNum).."p#",self.reviewString)
      --msg("#review"..Inspect(negNum).."n"..Inspect(posNum).."p#",Inspect(self.reviewFragsNeg))

      --msg("#review"..Inspect(negNum).."n"..Inspect(posNum).."p#",Inspect(self.reviewFragsPos))
      self.rating=math.floor(self.rating)


      for i=1,negNum do
        T.clearVar("negfrag"..Inspect(i))
      end
      for i=1,posNum do
        T.clearVar("posfrag"..Inspect(i))
      end

    else
      self.reviewString="#good#"
      self.rating=5
    end
    return Review(T.parse(self.reviewString),self.rating,self.id)
  end;
  addReviewFrag=function(self,frag,posOrNeg)
      if(posOrNeg=="pos")then
        self.reviewFragsPos[#self.reviewFragsPos+1]=frag
      else
        self.reviewFragsNeg[#self.reviewFragsNeg+1]=frag
      end
  end;
  findRoom=function(self,floorId)
    self.floorId=floorId
    self.roomId=floors[floorId]:getVacantRoom()
    if(self.roomId~=nil)then
      floors[self.floorId].rooms[self.roomId]:assignMortal(self.id)
      self.target={x=floors[self.floorId].rooms[self.roomId].x+(newsFeedWidth+motelXOffset)+roomWidth*4,y=floors[self.floorId].rooms[self.roomId].y+230+motelYOffset-((floorId-1)*floors[1].height)}
    end
  end;
  leave=function(self)

    local info=getPossibleFaults(self.floorId)
    faults=info.faults
    positives=info.positives
    fLim=clamp(#faults,0,3)
    for i=1,fLim do
      fault=choosePop(faults)
      --love.window.showMessageBox("fault", Inspect(fault), "info", true)
      local problemIdToNotify=nil
      if(fault.id~=nil)then if(problems[fault.id].appeared==false)then problemIdToNotify=fault.id end end
      self:addReviewFrag(ReviewFragment(fault.text,fault.rating,1,problemIdToNotify),"neg")
    end
    pLim=clamp(#positives,0,3)
    for i=1,pLim do
      positive=choosePop(positives)
      --love.window.showMessageBox("fault", Inspect(fault), "info", true)
      self:addReviewFrag(ReviewFragment(positive.text,positive.rating,1,nil),"pos")
    end


    money=money+self.stay*mortalPayMultiplier*self.stats["pay"]
    --if not very clean person
    if(self.stats["clean"]<3)then
      floors[self.floorId]:makeDirtier(0.3*(3-self.stats["clean"])/3)
    end
  	addToNewsFeed(self:getFinalReview(3))
    if(self.type=="cop" and not(self.possessed))then

      local bribeName=string.format("Bribe %s",self.lastName)
      newProblem(bribeName,nil,true,availableFunc,1,function(self)
        if(self.timer<=0)then
          upgrades[self.upgradeId]:makeUnavailable()
          self.active=false
          addInvestigationProgress(0.1)
        else
          self.timer=self.timer-1
        end
        local timeString=string.format("(%.2f hrs left)",getHours(self.timer))
        if(self.timer>dayLen)then
          timeString=string.format("(%i days left)",self.timer/dayLen)
        end
        upgrades[self.upgradeId].name=string.format("%s %s",self.name,timeString)
      end,nil,nil,nil,nil,nil,nil,nil)
      --set timer
      problems[#problems].timer=dayLen*4
      newUpgrade(bribeName,nil,150+math.floor(investigationProgress*2000),nil,{bribeName},nil)
      --set upgradeID
      problems[#problems].upgradeId=#upgrades
    end
  end;
  goMissing=function(self,why)
    --why=murder,shadow,statue,boil,freeze

    --if not left
    if(self.state=="STAYING")then
      money=money+self.stay*0.45

      if(why=="murder")then
        floors[self.floorId]:makeBloody()
      	addToNewsFeed(Review(T.parse("I enjoyed my stay, even if was cut short unexpectedly."),5,self.id))
        evilPercAdd(0.05)
      elseif(why=="shadow")then
        floors[self.floorId]:makeBloody()
        addToNewsFeed(Review(T.parse("THE BEAST CONSUMES"),5,self.id))
        evilPercAdd(0.08)
      elseif(why=="statue")then
        floors[self.floorId]:makeBloody()
      	addToNewsFeed(Review(T.parse("THE BEAST CONSUMES"),5,self.id))
        evilPercAdd(0.1)
      elseif(why=="boil")then
      	addToNewsFeed(Review(T.parse("It was too hot for me, but overall pretty good."),5,self.id))
        evilPercAdd(0.07)
      elseif(why=="freeze")then
      	addToNewsFeed(Review(T.parse("It was too chilly for me, but great overall."),5,self.id))
        evilPercAdd(0.07)
      end
    end

    self.state="MISSING"
    missingMortalsNo=missingMortalsNo+1
    self.x=window.w+100

    floors[self.floorId].rooms[self.roomId]:deassignMortal()
  end;
}


--mortalTypes={{"normal",0.9},{"murderer",0.06},{"cop",0.04}}
mortalTypes={{"normal",1.0},{"murderer",0.00},{"cop",0.00}}
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
