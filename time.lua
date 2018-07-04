time2=0
dayLen=10000

function getHours(timeToGet)
  local time3=timeToGet
  weeks=1
  days=1
  hours=0
  mins=0
  while(time3>0)do
    if(time3>dayLen*7)then
      weeks=weeks+1
      time3=time3-(dayLen*7)
    elseif(time3>dayLen)then
      days=days+1
      time3=time3-dayLen
    elseif(time3>dayLen/24)then
      hours=hours+1
      time3=time3-(dayLen/24)
    elseif(time3>dayLen/24/60)then
      mins=mins+1
      time3=time3-(dayLen/24/60)
    else
      time3=-1
    end
  end
  return hours+(mins/60)
end

function getDateText(timeToGet)
  local time3=timeToGet
  weeks=1
  days=1
  hours=0
  mins=0
  while(time3>0)do
    if(time3>dayLen*7)then
      weeks=weeks+1
      time3=time3-(dayLen*7)
    elseif(time3>dayLen)then
      days=days+1
      time3=time3-dayLen
    elseif(time3>dayLen/24)then
      hours=hours+1
      time3=time3-(dayLen/24)
    elseif(time3>dayLen/24/60)then
      mins=mins+1
      time3=time3-(dayLen/24/60)
    else
      time3=-1
    end
  end
  return string.format("D%d",((weeks-1)*7)+days)
end
function getDateTextFull(timeToGet)
  local time3=timeToGet
  weeks=1
  days=1
  hours=0
  mins=0
  while(time3>0)do
    if(time3>dayLen*7)then
      weeks=weeks+1
      time3=time3-(dayLen*7)
    elseif(time3>dayLen)then
      days=days+1
      time3=time3-dayLen
    elseif(time3>dayLen/24)then
      hours=hours+1
      time3=time3-(dayLen/24)
    elseif(time3>dayLen/24/60)then
      mins=mins+1
      time3=time3-(dayLen/24/60)
    else
      time3=-1
    end
  end
  return string.format("Week %d Day %d (%d %d)",weeks,days,hours,mins)
end
