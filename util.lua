
--USEFUL FUNCTIONS

function clamp(x,min,max)
	res=x
	if(x>max)then res=max
	elseif(x<min) then res=min end
	return res
end;
function sqr(x)
	return x*x
end;

function dist(x1,y1,x2,y2)
	return math.sqrt(sqr(math.abs(y2-y1))+sqr(math.abs(x2-x1)))
end;

function inBox(x1,y1,x,y,w,h)
	return x1>x and x1<x+w and y1>y and y1<y+h
end;

function inTable(el,t)
	for _,x in pairs(t) do
		if x==el then return true end
	end
	return false
end

function inTableKeys(key,t)
	for k,v in pairs(t) do
		if k==key then return true end
	end
	return false
end

function areaTri(p1,p2,p3)
    a1=dist(p1,p2)
    b1=dist(p2,p3)
    c1=dist(p3,p1)
    s=(a1+b1+c1)/2;
    res=math.sqrt(math.abs(s*(s-a1)*(s-b1)*(s-c1)));
    return res;
end
function isPointInQuad(point,quadPoints,quadArea)
    areas={
        areaTri(quadPoints[1],point,quadPoints[4]),
        areaTri(quadPoints[4],point,quadPoints[3]),
        areaTri(quadPoints[3],point,quadPoints[2]),
        areaTri(point,quadPoints[2],quadPoints[1])
    }
    if(areas[0]+areas[1]+areas[2]+areas[3]==quadArea)then
        return true
    else
        return false
    end
end

function rotateDrawRect(x,y,w,h,angle,mode)
  love.graphics.translate(x, y)
  love.graphics.rotate(angle)
  love.graphics.rectangle(mode, -w/2, -h/2, w, h)
  love.graphics.rotate(-angle)
  love.graphics.translate(-x, -y)
end

function HSL(h,s,l,a)
  if s<=0 then return l,l,l,a end
  h,s,l=h/256*6,s/255,l/255
  local c=(l-math.abs(2*l-1))*s
  local x=(l-math.abs(h%2-1))*c
  local m,r,g,b=(l-.5*c),0,0,0
  if h<1 then r,g,b=c,x,0
  elseif h<2 then r,g,b=x,c,0
  elseif h<3 then r,g,b=0,c,x
  elseif h<4 then r,g,b=0,x,c
  elseif h<5 then r,g,b=x,0,c
  else r,g,b=c,0,x end
  return (r+m)*255,(g+m)*255,(b+m)*255,a
end

function drawTextInBoxChars(text,fW,fH,x,y,w)
	--round up (length of string * char width) / width of box
	lineNo=math.ceil((#text*fW)/w)
	charPerLine=math.ceil(#text/lineNo)
	--love.window.showMessageBox("title", "lines: "..lineNo.."\ntextLen: "..#text.."\ncharWidth: "..fW.."\nboxWidth: "..w.."\ncharPerLine: "..charPerLine, "info", true)
	stringToPrint=string.sub(text, 1, 1)
	for i=2,#text do
		if(math.fmod(i,charPerLine)==1)then
			stringToPrint=stringToPrint.."\n"
		end
		stringToPrint=stringToPrint..string.sub(text, i, i)
	end

	love.graphics.print(stringToPrint, x, y)

	--return height
	return lineNo*fH
end

function drawTextInBox(text,fW,fH,x,y,w)
	--round up (length of string * char width) / width of box
	charsInLine=0
	lineNo=1
	wordToAdd=""
	stringToPrint=""
	for i=1,#text do
		--love.window.showMessageBox("text"..Inspect(i), Inspect(wordToAdd), "info", true)
		if(string.sub(text,i,i)==" " or i==#text)then
			if((charsInLine+#wordToAdd)*fH>=w)then
				stringToPrint=stringToPrint.."\n"
				charsInLine=0
				lineNo=lineNo+1
			end
			stringToPrint=stringToPrint.." "..wordToAdd
			charsInLine=charsInLine+#wordToAdd
			wordToAdd=""
		else
			wordToAdd=wordToAdd..string.sub(text,i,i)
		end
	end
	stringToPrint=stringToPrint..string.sub(text,#text,#text)
	love.graphics.print(stringToPrint, x, y)

	--return height
	return lineNo*fH
end
