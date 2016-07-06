/*defining the different factions*/
enum FACTION      {BLAU, ROT, NEUTRAL, TEST}

/*defining the different row types for the play phase*/
enum ROWTYPE      {SIEGE, DIST, CLOSE}

/*making each row distinct*/
enum ROWTYPEDIST  {AISIEGE, AIDIST, AICLOSE, PLAYERSIEGE, PLAYERDIST, PLAYERCLOSE}

/*used for identifying the possible effects a card can have*/
enum EFFECTS      {BROTHERHOOD, HORN, HEALER, MORALEBOOST, SPY, WEATHER, GOODWEATHER}

/*defining the different player types*/
enum PLAYERTYPE   {PLAYER, AI}

/*defining the different phases of a pint game*/
enum GAMEPHASE    {LOGIN, PREPAREDECK, PLAY, DISPLAYRESULT}