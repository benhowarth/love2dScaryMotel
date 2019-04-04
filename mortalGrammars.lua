T.addGrammarTable("review1",{"@frag1@.","All I have to say is @frag1@."})
T.addGrammarTable("review2",{"#review1# Also, @frag2@.","#review1# On top of that, @frag2@.","@frag1@ and @frag2@."})
T.addGrammarTable("review3",{"#review2# Not to mention, @frag3@.","#review2# Other than that, @frag3@."})


T.addGrammarTable("review0n1p",{"@posfrag1@.","All I have to say is @posfrag1@."})
T.addGrammarTable("review0n2p",{"@posfrag1@ and @posfrag2@.","@posfrag1@ also, @posfrag2@."})
T.addGrammarTable("review0n3p",{"@posfrag1@, @posfrag2@ and @posfrag3@.","@posfrag1@ also @posfrag2@ and @posfrag3@"})
T.addGrammarTable("review1n0p",{"@negfrag1@.","All I have to say is @negfrag1@."})
T.addGrammarTable("review1n1p",{"@posfrag1@, but @negfrag1@.","@negfrag1@, however @posfrag1@."})
T.addGrammarTable("review1n2p",{"@negfrag1@, but @posfrag1@ and @posfrag2@.","@posfrag1@ and @posfrag2@, other than that @negfrag1@."})
T.addGrammarTable("review2n0p",{"@negfrag1@ and @negfrag2@."})
T.addGrammarTable("review2n1p",{"@negfrag1@, @negfrag2@ however @posfrag1@."})
T.addGrammarTable("review3n0p",{"@negfrag1@, @negfrag2@ and @negfrag3@."})


T.addGrammarTable("nice",{"nice","good","pleasant"})
T.addGrammarTable("experience",{"experience","time","stay"})
T.addGrammarTable("good",{"I had a #nice# #experience#."})

T.addGrammarTable("them",{"them","the beast"})

T.addGrammarTable("praiseThem",{"praise #them#","give glory to #them#","give my devotion to #them#","give thanks to #them#"})
T.addGrammarTable("possessedGood",{"I had a #nice# #experience# learning to #praiseThem#."})

T.addGrammarTable("hello",{"hey.","yeah?","huh?","whats this about?"})
T.addGrammarTable("copHello",{"evening"})
T.addGrammarTable("creepyHello",{"hello?"})

require "res/firstNames"
require "res/lastNames"

T.addGrammarTableFromString("firstName",firstNamesString)
T.addGrammarTableFromString("lastName",lastNamesString)

T.addGrammarTable("num",{"1","2","3","4","5","6","7","8","9"})
T.addGrammar("age","#num##num#")
T.addGrammarTable("sportsTeam",{"bulls","eagles","birds","sharks"})
T.addGrammarTable("sportsTeamSupport",{"Go #sportsTeam#","#sportsTeam# for life"})
T.addGrammarTable("company",{"#lastName# inc","#lastName# and #lastName#"})
T.addGrammarTable("departmentAdj",{"global","human"})
T.addGrammarTable("departmentBit",{"marketing","resources","finance"})
T.addGrammarTable("department",{"#departmentBit#","#departmentAdj# #departmentBit#","#departmentBit# and #departmentBit#"})
T.addGrammarTable("bioAdj",{"creative","curious","grumpy","professional","24 7"})
T.addGrammarTable("bioVerb",{"love","live","travel","eat","worship"})
T.addGrammarTable("bioDescriptor",{"traveller","foodie","gamer","christian","web developer","code monkey","ranter","intern at #company#","head of #department# at #company#"})
T.addGrammarTable("bio",{"#bioDescriptor#, #age#.","#bioAdj# #bioDescriptor#","#bioVerb#. #bioVerb#. #bioVerb#.","#sportsTeamSupport#!"})


--T.addGrammarTable("copBio",{"Not a cop!"})
T.addGrammarTable("love",{"love","all about","need that"})
T.addGrammarTable("law",{"the law","the rules","structure"})
T.addGrammarTable("proud",{"proud","dedicated","loving"})
T.addGrammarTable("officer",{"officer","detective","cop"})
T.addGrammarTable("copBio",{"#love# #law#.","#proud# #officer#."})

T.addGrammarTable("creepyNoun",{"skins","hair","anatomy","taxidermy"})
T.addGrammarTable("collector",{"collector","curator"})
T.addGrammarTable("creepyBio",{"#love# #creepyNoun#.","#creepyNoun# #collector#."})
