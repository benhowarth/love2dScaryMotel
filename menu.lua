draggables={}
Draggable=Class{
  init=function(self,id,name,x,y,w,h,img,tooltipText)
    self.id=id
    self.name=name
    self.x=x
    self.y=y
    self.mouseOffsetX=0
    self.mouseOffsetY=0
    self.w=w
    self.h=h
    self.img=img
    self.tooltipText=tooltipText
  end;
  update=function(self,XMin,XMax,YMin,YMax)
    if(cursorPickedUp==self.id)then
      self.x=mouseX-self.mouseOffsetX
      self.y=mouseY-self.mouseOffsetY
    end
    self.x=clamp(self.x,XMin,XMax-self.w)
    self.y=clamp(self.y,YMin,YMax-self.h)


  end;
  draw=function(self)
    if(self.img==nil)then
      love.graphics.setColor(0, 0, 0, 255)
      love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.print(self.name, self.x,self.y)
    else
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.draw(draggableImgs[self.img],self.x,self.y,0,self.w/draggableImgs[self.img]:getWidth(),self.h/draggableImgs[self.img]:getHeight())
    end

    love.graphics.setColor(255, 0, 0, 255)
    love.graphics.circle("fill",self.x+self.w/2,self.y,7)
  end;
}
function newDraggable(name,x,y,w,h,img,tooltipText)
  draggables[#draggables+1]=Draggable(#draggables+1,name,x,y,w,h,img,tooltipText)
end

corkBoard={
  x=100,
  y=100,
  w=600,
  h=400,
  buffer=20
}
cursorPickedUp=nil

calendar={
  w=200,
  h=200
}
calendar.x=800
calendar.y=100
weekNo=4
calendar.cells={}
for we=1,weekNo do
  calendar.cells[we]={}
    for day=1,7 do
      calendar.cells[we][day]=0
    end
end
--calendar.cells[1][1]=1
--msg("calendar cells",Inspect(calendar))
calendar.onClick=function()
  local curCellX=calendar.x
  local curCellY=calendar.y
  local cellH=calendar.h/#calendar.cells
  local cellW=calendar.w/#calendar.cells[1]
  for we=1,#calendar.cells do
      for day=1,#calendar.cells[we] do
        if(inBox(mouseX,mouseY,curCellX,curCellY,cellW,cellH))then
          --msg("Calendar Click",string.format("W:%d D:%d value:%d",we,day,calendar.cells[we][day]))
          if(calendar.cells[we][day]==2)then inGame=true paused=false pauseIcon="❚❚" end
        end
        curCellX=curCellX+cellW
      end
      curCellY=curCellY+cellH
  end
end;
daysofweek={"Mo","Tu","We","Th","Fr","Sa","Su"}
calendar.draw=function()
  love.graphics.setColor(0,0,120,255)
  love.graphics.rectangle("fill",calendar.x-10,calendar.y-20,calendar.w+20,calendar.h+60)
  love.graphics.setColor(255,255,255,255)
  love.graphics.print("August",calendar.x+60,calendar.y+calendar.h+20)
  love.graphics.rectangle("line",calendar.x,calendar.y,calendar.w,calendar.h)
  local curCellX=calendar.x
  local curCellY=calendar.y
  local cellH=calendar.h/#calendar.cells
  local cellW=calendar.w/#calendar.cells[1]
  local timeSum=time2
  love.graphics.setLineWidth(3)
  for we=1,#calendar.cells do
      curCellX=calendar.x
      for day=1,#calendar.cells[we] do

        love.graphics.setColor(255,255,255,255)
        if(we==1)then
          love.graphics.print(daysofweek[day],curCellX,calendar.y-20)
        end
        love.graphics.rectangle("fill",curCellX,curCellY,cellW,cellH)
        if(timeSum>=dayLen)then calendar.cells[we][day]=1 elseif(timeSum>=0)then calendar.cells[we][day]=2 end
        if(calendar.cells[we][day]==1)then
          love.graphics.setColor(255,0,0,255)
          love.graphics.line(curCellX,curCellY,curCellX+cellW,curCellY+cellH)
          love.graphics.line(curCellX,curCellY+cellH,curCellX+cellW,curCellY)
        elseif(calendar.cells[we][day]==2)then
          love.graphics.setColor(255,0,0,255)
          love.graphics.ellipse("line", curCellX+cellW/2,curCellY+cellH/2,cellW/2,cellH/2)
        end
        love.graphics.setColor(0,0,120,255)
        love.graphics.rectangle("line",curCellX,curCellY,cellW,cellH)
        curCellX=curCellX+cellW
        timeSum=timeSum-dayLen
      end
      curCellY=curCellY+cellH
  end
  love.graphics.setColor(255,255,255,255)
  love.graphics.setLineWidth(1)
end;

officeWindow={
  x=window.w-800,
  y=100,
  w=425,
  h=600,
}

bulb={
  x=window.w,
  y=60,
  angle=0,
  on=true
}
menu={}
menuTime=0
toolTipShowId=nil
menu.update=function()
  toolTipShowId=nil
  menuTime=menuTime+1
  for d=1,#draggables do
      draggables[d]:update(corkBoard.x,corkBoard.x+corkBoard.w,corkBoard.y,corkBoard.y+corkBoard.h)
      --msg("draggables"..Inspect(d),Inspect(toolTipShowId))
      if(inBox(mouseX,mouseY,draggables[d].x,draggables[d].y,draggables[d].w,draggables[d].h)) then
        toolTipShowId=d
      end
  end
  if(toolTipShowId~=nil)then
    queueMenuBox({draggables[toolTipShowId].tooltipText},0,fontCharWidth,fontCharHeight,mouseX,mouseY,300)
  end

  bulb.angle=(math.sin(menuTime*0.01))/2
  bulb.x=(window.w/2)+(bulb.angle*20)
  bulb.y=60-(math.abs(bulb.angle)*10)
end;

menu.draw=function()
  --wall
  love.graphics.setColor(100,100,150)
  love.graphics.rectangle("fill",0,0,window.w,officeWindow.y+officeWindow.h+120)

  --carpet
  love.graphics.setColor(150,100,100)
  love.graphics.rectangle("fill",0,officeWindow.y+officeWindow.h+120,window.w,window.h)

  love.graphics.setColor(111, 34, 19)
  love.graphics.rectangle("fill", corkBoard.x-corkBoard.buffer, corkBoard.y-corkBoard.buffer, corkBoard.w+corkBoard.buffer*2, corkBoard.h+corkBoard.buffer*2)
  love.graphics.setColor(122, 45, 30)
  love.graphics.rectangle("fill", corkBoard.x, corkBoard.y, corkBoard.w, corkBoard.h)
  love.graphics.setColor(255,255,255)
  for d=1,#draggables do
      draggables[d]:draw()
  end
  calendar.draw()
  drawClock(window.w-100,100,50,getHours(time2),math.fmod(getHours(time2),1)*60,true)

  	drawMenuBoxesQueued()


  --frame
  love.graphics.setColor(122, 45, 30)
  love.graphics.rectangle("fill",officeWindow.x-35,officeWindow.y-50,officeWindow.w+100,officeWindow.h+120+50)

  --handle
  love.graphics.setColor(150,150,150)
  love.graphics.rectangle("fill",officeWindow.x+officeWindow.w+10,officeWindow.y+officeWindow.h/2,30,10)

  --sky
  love.graphics.setColor(grayLevel, grayLevel, grayLevel)
  love.graphics.rectangle("fill",officeWindow.x,officeWindow.y,officeWindow.w,officeWindow.h)
  local stencil = function()
    love.graphics.rectangle("fill",officeWindow.x,officeWindow.y,officeWindow.w,officeWindow.h)
  end

  love.graphics.stencil(stencil,"replace",1)
  love.graphics.setStencilTest("greater", 0)
  M.print(officeWindow.x-40,officeWindow.y+officeWindow.h*0.6,5,fontCharWidth,fontCharHeight)

  --window bit
  love.graphics.setColor(0, 90, 160,50)
  love.graphics.rectangle("fill",officeWindow.x,officeWindow.y,officeWindow.w,officeWindow.h)
  love.graphics.setStencilTest()


  --bulb
  love.graphics.setColor(252, 226, 166)
  love.graphics.setLineWidth(10)
  love.graphics.line(bulb.x+math.sin(-bulb.angle*0.3)*20,bulb.y-math.cos(-bulb.angle*0.3)*24,window.w/2,-30)
  love.graphics.setLineWidth(1)

  love.graphics.setColor(255, 255, 255,255)
  love.graphics.push()
  love.graphics.translate(bulb.x,bulb.y)
  love.graphics.rotate(-bulb.angle*0.3)
  --love.graphics.circle("fill",bulb.x,bulb.y,20)
  love.graphics.circle("fill",0,0,20)
  --love.graphics.rectangle("fill",bulb.x-10,bulb.y-30,20,30)
  love.graphics.rectangle("fill",-10,-30,20,30)
  love.graphics.pop()


  love.graphics.setColor(252, 226, 166)
  --love.graphics.rectangle("line",bulb.x-30,bulb.y-30,60,60)
  love.graphics.rectangle("fill",window.w-250,400,40,60)

  if(bulb.on)then
  love.graphics.setColor(50, 35, 20)
  love.graphics.rectangle("fill",window.w-250+15,400+15,10,15)

  love.graphics.setColor(200, 180, 100)
  love.graphics.rectangle("fill",window.w-250+15,400+30,10,15)

  else
  love.graphics.setColor(200, 180, 100)
  love.graphics.rectangle("fill",window.w-250+15,400+15,10,15)

  love.graphics.setColor(50, 35, 20)
  love.graphics.rectangle("fill",window.w-250+15,400+30,10,15)
  end


  love.graphics.setColor(255,255,255)
end;


menu.onClick=function()
  if(inBox(mouseX,mouseY,officeWindow.x,officeWindow.y,officeWindow.w,officeWindow.h)) then inGame=true paused=false pauseIcon="❚❚" end
  if(inBox(mouseX,mouseY,window.w-250,400,40,60)) then if(bulb.on)then bulb.on=false else bulb.on=true end end
  for d=1,#draggables do
    dr=draggables[d]
    if(inBox(mouseX,mouseY,dr.x,dr.y,dr.w,dr.h))then
      cursorPickedUp=d
      draggables[d].mouseOffsetX=mouseX-dr.x
      draggables[d].mouseOffsetY=mouseY-dr.y
    end
  end
  calendar.onClick()
end;
menu.onUnclick=function()
  cursorPickedUp=nil
end


menu.keyPressed=function()
end;

menu.keyReleased=function()
end;

draggableImgs={}
draggableImgs.letter=love.graphics.newImage("res/draggable_letter.png");
draggableImgs.photo=love.graphics.newImage("res/draggable_photo.png");
draggableImgs.map=love.graphics.newImage("res/draggable_map.png");
draggableImgs.policeLetter=love.graphics.newImage("res/draggable_policeLetter.png")

newDraggable("letter",0,0,80,150,"letter","A letter from the previous owner. It explains you just leave through the door to manage the motel, mentions something about burying something repeatedly and tails off into sentences too scribbly to make out.")
newDraggable("photo",0,0,40,50,"photo","A photo of a picnic(?)")
newDraggable("map",0,0,200,200,"map","A map of some sort.")
