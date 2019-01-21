function choose(t)
	return (t[math.random(1, #t)])
end
function choosePop(t)
	i=math.random(1, #t)
	a=t[i]
	table.remove(t,i)
	return a
end
local T={}
T.variables={}
T.setVar=function(varName,val)
	T.variables[varName]=val
end
T.clearVar=function(varName)
	T.variables[varName]=nil
end
T.grammar={}

T.addGrammar=function(key,value)
	if(T.grammar[key]~=nil)then T.grammar[key][#T.grammar[key]+1]=value
	else T.grammar[key]={value} end
end
T.addGrammarTable=function(key,valueTable)
	for _,v in pairs(valueTable)do
		T.addGrammar(key,v)
	end
end
T.addGrammarTableFromFile=function(key,filename)
	--https://stackoverflow.com/questions/12855988/file-to-array-in-lua
	local file = io.open(filename, "r");
	local arr = {}
	for line in file:lines() do
	  table.insert (arr, line);
	end
	T.addGrammarTable(key,arr)
end
T.parse=function(str)
	indexTemp=-1
	nextPick=""
	res=""
	cur=nil

	for i=1,#str do

		local c = str:sub(i,i)
		--love.window.showMessageBox(Inspect(i)..":"..c,Inspect(res).."//"..Inspect(nextPick),"info",false)
		if(c=="#" or c=="@")then
			if(c=="#")then cur="#" elseif(c=="@") then cur="@" end
			if(indexTemp==-1)then
				indexTemp=i
			else
				if(cur=="#")then
					--res=res..choose(T.grammar[nextPick])
					if(inTableKeys(nextPick,T.grammar))then
						res=res..T.parse(choose(T.grammar[nextPick]))
					else
						res=res.."#"..nextPick.."#"
					end
				elseif(cur=="@")then
					--msg("res",res.."\n"..nextPick.."\n"..T.variables[nextPick])
					if(T.variables[nextPick]~=nil)then
						res=res..T.parse(T.variables[nextPick])
					else
						res=res.."@"..nextPick.."@"
					end
				end
				nextPick=""
				indexTemp=-1
			end
		else
			if(indexTemp==-1)then
				res=res..c
			else
				nextPick=nextPick..c
			end
		end

	end
	return res

end

return T
