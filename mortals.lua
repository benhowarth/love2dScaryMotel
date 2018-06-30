T.addGrammarTable("review1",{"@frag1@.","All I have to say is @frag1@."})
T.addGrammarTable("review2",{"#review1# Also, @frag2@.","#review1# On top of that, @frag2@.","@frag1@ and @frag2@."})
T.addGrammarTable("review3",{"#review2# Not to mention, @frag3@.","#review2# Other than that, @frag3@."})
mortals={}
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
  end;
  print=function(self,fW,fH,x,y,w)
    love.graphics.draw(mortalBase, x+15, y+15, 0,5,5)
    love.graphics.draw(mortalTop[mortals[self.mortalId].top], x+15, y+15, 0,5,5)
    love.graphics.draw(mortalBottom[mortals[self.mortalId].bottom], x+15, y+15, 0,5,5)
    love.graphics.rectangle("line", x+10, y+10, reviewPicWidth, reviewPicHeight)
    h=drawTextInBox(self.text,fW,fH,x+reviewPicWidth+20,y+10,w-reviewPicWidth-20)
    love.graphics.setFont(fontDefault)
    love.graphics.print(getRatingText(self.rating),x+10,y+reviewPicHeight+20)
    love.graphics.setFont(fontSpooky)
    love.graphics.print(getDateText(self.date),x+10,y+reviewPicHeight+40)

    if(h<reviewPicWidth+fH+50)then h=reviewPicWidth+fH+50 end
    love.graphics.print("-"..mortals[self.mortalId].name,x+reviewPicWidth+20,y+h+fH)

    h=h+fH*3

    love.graphics.rectangle("line", x, y, w, h)
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
  init=function(self,id,name)
    self.id=id
    self.name=name
    self.reviewFrags={}
    self.reviewString=""
    self.rating=0
    self.x=newsFeedWidth+10
    self.y=230
    self.state=-1
    self.stay=(math.random()*300)+100
    self.stayTimer=0
    self.top=math.ceil(math.random()*#mortalTop)
    self.bottom=math.ceil(math.random()*#mortalBottom)
  end;
  update=function(self)
    --entering
    if(self.state==-1)then
      self.x=self.x+3
      if(self.x>newsFeedWidth+80)then
        self.state=0
      end
    --staying
    elseif(self.state==0)then
      self.stayTimer=self.stayTimer+1
      if(self.stayTimer>self.stay)then
        self.x=window.w-100
        self.state=1
      end
    --leaving
    elseif(self.state==1)then
      self.x=self.x+4
      if(self.x>window.w)then
        self:leave()
      end
    end
  end;
  draw=function(self)
    if(self.state~=2 and self.state~=0)then
      love.graphics.draw(mortalBase, self.x, self.y, 0,5,5,5,5)
      love.graphics.draw(mortalTop[self.top], self.x, self.y, 0,5,5,5,5)
      love.graphics.draw(mortalBottom[self.bottom], self.x, self.y, 0,5,5,5,5)
      --love.graphics.rectangle("fill", self.x, self.y, 30, 30)
    end
  end;
  getFinalReview=function(self,fragNumber)
    table.sort(self.reviewFrags,function(a,b) return a.weight>b.weight end)
    if(#self.reviewFrags<fragNumber)then fragNumber=#self.reviewFrags end
    if(#self.reviewFrags~=0)then
      self.rating=0
      for i=1,fragNumber do
        T.setVar("frag"..Inspect(i),self.reviewFrags[i].text)
        --self.reviewString=self.reviewString.." "..self.reviewFrags[i].text
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
  leave=function(self)
    self.state=2

    faults=getPossibleFaults()
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
}

newMortal=function()
  mortals[#mortals+1]=Mortal(#mortals+1,T.parse("#firstName# #lastName#"))
end;

howManyMortalsStaying=function()
  mortalNum=0
  for h=1,#mortals do
    if(mortals[h].state==0)then mortalNum=mortalNum+1 end
  end
  return mortalNum
end


T.addGrammarTableFromFile("firstName","res/firstNames.txt")
T.addGrammarTableFromFile("lastName","res/lastNames.txt")
