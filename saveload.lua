local binser=require 'lib.binser'

--binser.register()


function saveData()
  msg("save","attempting to save data")
  --get save file
  saveFileExists=love.filesystem.exists("save1.sav")
  --get data to write to save
  dataToWrite={}
  dataToWrite["gameBooted"]=gameBooted
  dataToWrite["inGame"]=inGame
  dataToWrite["time"]=time
  dataToWrite["time2"]=time2
  dataToWrite["money"]=money
  dataToWrite["floors"]=floors
  dataToWrite["mortals"]=mortals
  dataToWrite["newsFeed"]=newsFeed
  dataToWrite["upgrades"]=upgrades
  dataToWrite["evilPerc"]=evilPerc
  dataToWrite["problems"]=problems
  dataToWrite["draggables"]=draggables
  dataToWrite["missingMortalsNo"]=missingMortalsNo
  dataToWrite["lastInvestigationProgress"]=lastInvestigationProgress
  dataToWrite["investigationProgress"]=investigationProgress
  dataToWrite["tutorialMessagesShown"]=tutorialMessagesShown
  dataToWrite["shadows"]=shadows
  dataToWrite["cats"]=cats
  dataToWrite["cats2"]=cats2
  dataToWrite["hotdogs"]=hotdogs
  dataToWrite["gameEnd"]=gameEnd
  dataToWrite["statueHelpCounter"]=statueHelpCounter


  dataToWriteString=binser.serialize(dataToWrite)
  if(saveFileExists)then
    --overwrite save
    love.filesystem.write("save1.sav",dataToWriteString)
    msg("save","save data found and overwritten")
  else
    --write new save
    love.filesystem.newFile("save1.sav")
    love.filesystem.write("save1.sav",dataToWriteString)
    msg("save","no save data found, new file created")
  end

end

function loadData()
  msg("load","attempting to load data")
  --get save file
  saveFileExists=love.filesystem.exists("save1.sav")
  if(saveFileExists)then
    saveFileString=love.filesystem.read("save1.sav")
    local saveResults,saveLength=binser.deserialize(saveFileString)
    msg("load","data loaded successfully (len: "..Inspect(saveLength)..")")
    --msg("load","DATA:\n"..Inspect(saveResults))
    --msg("load","DATA money:\n"..Inspect(saveResults[1]["money"]))
    --do something with saveResults
    local res=saveResults[1]

    --msg("probs Pre-load"..#problems,Inspect(problems[13]))
    for i=1,#res["upgrades"] do
      --msg("upgrades load"..i,"pre:"..Inspect(res["upgrades"][i]).."\npost:"..Inspect(upgrades[i]))
    end

    gameBooted=res["gameBooted"]
    inGame=res["inGame"]
    paused=true
    pauseIcon="▶"
    time=res["time"]
    time2=res["time2"]
    money=res["money"]
    upgrades=res["upgrades"]
    mortals=res["mortals"]
    newsFeed=res["newsFeed"]
    floors=res["floors"]
    evilPerc=res["evilPerc"]
    problems=res["problems"]
    draggables=res["draggables"]
    missingMortalsNo=res["missingMortalsNo"]
    lastInvestigationProgress=res["lastInvestigationProgress"]
    investigationProgress=res["investigationProgress"]
    tutorialMessagesShown=res["tutorialMessagesShown"]
    shadows=res["shadows"]
    cats=res["cats"]
    cats2=res["cats2"]
    hotdogs=res["hotdogs"]
    gameEnd=res["gameEnd"]
    statueHelpCounter=res["statueHelpCounter"]


  else
    msg("load","no save data found")
  end
end
