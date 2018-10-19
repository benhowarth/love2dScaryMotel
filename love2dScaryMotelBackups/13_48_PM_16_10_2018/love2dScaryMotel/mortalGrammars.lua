T.addGrammarTable("review1",{"@frag1@.","All I have to say is @frag1@."})
T.addGrammarTable("review2",{"#review1# Also, @frag2@.","#review1# On top of that, @frag2@.","@frag1@ and @frag2@."})
T.addGrammarTable("review3",{"#review2# Not to mention, @frag3@.","#review2# Other than that, @frag3@."})

T.addGrammarTableFromFile("firstName","res/firstNames.txt")
T.addGrammarTableFromFile("lastName","res/lastNames.txt")

T.addGrammarTable("num",{"1","2","3","4","5","6","7","8","9"})
T.addGrammar("age","#num##num#")
T.addGrammarTable("bioAdj",{"creative"})
T.addGrammarTable("bioVerb",{"love","live","travel","eat","worship"})
T.addGrammarTable("bioDescriptor",{"traveller","creative","foodie","gamer","christian"})
T.addGrammarTable("bio",{"#bioDescriptor#, #age#.","#bioVerb#. #bioVerb#. #bioVerb#."})


T.addGrammarTable("copBio",{"Not a cop!"})



T.addGrammarTable("creepyBio",{"Creepy!"})
