T.addGrammarTable("review1",{"@frag1@.","All I have to say is @frag1@."})
T.addGrammarTable("review2",{"#review1# Also, @frag2@.","#review1# On top of that, @frag2@.","@frag1@ and @frag2@."})
T.addGrammarTable("review3",{"#review2# Not to mention, @frag3@.","#review2# Other than that, @frag3@."})


T.addGrammarTable("review0n1p",{"@posfrag1@.","All I have to say is @posfrag1@."})
T.addGrammarTable("review0n2p",{"@posfrag1@ and @posfrag2@.","@posfrag1 also, @posfrag2@."})
T.addGrammarTable("review0n3p",{"@posfrag1@, @posfrag2@ and @posfrag3@.","@posfrag1@ also @posfrag2@ and @posfrag3@"})
T.addGrammarTable("review1n0p",{"@negfrag1@.","All I have to say is @negfrag1@."})
T.addGrammarTable("review1n1p",{"@posfrag1@, but @negfrag1@.","@negfrag1@, however @posfrag1@."})
T.addGrammarTable("review1n2p",{"@negfrag1@, but @posfrag1@ and @posfrag2@.","@posfrag1@ and @posfrag2@, other than that @negfrag1@."})
T.addGrammarTable("review2n0p",{"@negfrag1@ and @negfrag2@."})
T.addGrammarTable("review2n1p",{"@negfrag1@, @negfrag2@ however @posfrag1@."})
T.addGrammarTable("review3n0p",{"Not only @negfrag1@ and @negfrag2@, but also @negfrag3@."})

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
