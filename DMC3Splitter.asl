/***************************** Created by Austin 'Auddy' Davenport ******************************************/
/******************************* Credits: Mysterion_06_ & Hies *********************************************/

//  Devil May Cry 3: Special Editon / HD Collection - Full Game Timer

state("dmc3")
{
	int bulletScreenHD : 0xCF2718;  			            // Bullet screens at the end of missions
	int falseStartHD : 0xC90DF8, 0x40; 			            // New Game+ start on mission select
	int finalBossHealthHD : 0xC90FC0, 0xEB28;	            // The final boss health
	int levelHD : 0xC8F250;  					            // The number of the level we are on
	int loadingScreenHD : 0x5D93E0;				            // The loading screens
	int mainMenuHD : 0xC9DDC4;					            // The main menu screen
	int menuTransitionHD : 0xC0CBB0;			            // Main menu transitions
	int NGStartHD : 0x5CF9F0; 					            // New Game start after hitting Gold on the menu
	int plusStartHD : 0x5D95DC; 				            // New Game+ start on mission select
    int roomID : 0xC8F258;                                  // current roomID u r in
    int LS : 0xCEF8E0;                                      // A pointer used to stop the timer when going thru doors or opening the menu
    int menuHD : 0xCF2680, 0xD8, 0x110, 0xC0, 0x2F8, 0xD0;  // When in the main menu
    int gold : 0xC8F340;                                    // Value of the owned gold orbs
}

state("dmc3se")
{
	int bulletScreen : 0x205CF14;  		// Bullet screens at the end of missions
	int danteBossHealth : 0x1A10710; 	// Dante's health when you fight him as Vergil
	int level : 0x381494;  				// The number of the level we are on
	int loadingScreen : 0x76BB20;  		// The black loading screens
    int gameState : 0x205BCB8;          // The game state, 0 normally, 1 when paused/entering new rooms
	int menu : 0x70D2E0; 				// The menu in general, changes numbers on different menus / inventory screens
	int NGStart : 0x70D2DC; 			// New Game start after hitting Gold on the menu
	int plusStart : 0x188EDB4; 			// New Game+ start on mission select
	int vergilBossHealth : 0x1A61510;  	// Vergil's health when you fight him as Dante
	int roomID : 0x2D3A74, 0x16C;		// Cuurrent Room ID
    int mainMenu : 0x188D72C;           // The main menu at the start
    int goldSelected : 0x76B158;        // Bool for whether gold orb is selected
    int costumeSelected : 0x76B214;     // Dante/Vergil's current costume ID
    int vHealth1 : 0x1A7B058;           // Vergil's health when using default costume/default with infinite dt
    int vHealth2 : 0x1A67C58;           // with shirtless costume
    int vHealth3 : 0x1A5BA58;           // with dmc1 costume
    int vHealth4 : 0x1A4A658;           // with dmc2 costume
    int vHealth5 : 0x1A5F658;           // with sparda/sparda with infinite dt
    int dHealth1 : 0x1A33858;           // Dante's health when using default costume/default with infinite dt
    int dHealth2 : 0x1A2B058;           // with shirtless costume
    int dHealth3 : 0x1A0E858;           // with sparda/sparda with infinite dt
    int bossHealthBar : 0x188CE84;      // Something to do with the boss health bar, not entirely sure, but it's consistent
    int resetNGPlus : 0x188EDC8;
    /*
        probably better to use a memory watcher function with the update state
        instead of constantly monitoring every address, however for now this works
    */
}

init
{
	vars.bulletSplit = 0;
    vars.split = 0;
}

startup
{
	settings.Add("version", true, "Version");
	settings.SetToolTip("version", "Do not uncheck this box");
	
	settings.CurrentDefaultParent = "version";
	settings.Add("HD", true, "HD");
    settings.CurrentDefaultParent = "HD";
    settings.Add("DS", false, "DoorSplitter");
	settings.SetToolTip("HD", "Check this option if you are running the HD Collection version of DMC3");
	
	settings.CurrentDefaultParent = "version";
	settings.Add("SE", false, "SE");
    settings.CurrentDefaultParent = "SE";
    settings.Add("SEDS", false, "SEDoorSplitter");
	settings.SetToolTip("SE", "Check this option if you are running the Special Edition version of DMC3");
	
	settings.CurrentDefaultParent = null;
	settings.Add("options", true, "Options");
	settings.CurrentDefaultParent = "options";
	settings.Add("LoadRemover", true, "Load Remover");
	settings.SetToolTip("LoadRemover", "Check this option if you want to use the Load Remover feature");
}

start
{
	// Settings for DMC3HD
	if(settings["HD"]){
		// Settings for New Game Start
		if(current.NGStartHD == 5 && old.NGStartHD == 4 && current.levelHD == 1 && current.falseStartHD != 1 && current.mainMenuHD != 0){
			vars.bulletSplit = 0;
			return true;
		}
		
		// Settings for New Game+ Start
		if(current.plusStartHD == 344 && old.plusStartHD == 272 && current.mainMenuHD != 650 && current.menuTransitionHD != 37476){
			vars.bulletSplit = 0;
			return true;
		}
	}

	/************************************************************************************/
	
	// Settings for DMC3SE
	if(settings["SE"]){
		// Settings for New Game Start
		if(current.NGStart == 7 && old.NGStart == 0 && current.level == 1){
			vars.bulletSplit = 0;
            vars.split = 0;
			return true;
		}
	
		// Settings for New Game+ Start
		if(current.plusStart == 1 && old.plusStart == 0){
			vars.bulletSplit = 0;
            vars.split = 0;
			return true;
		}
	}
}


split
{
	// Settings for DMC3HD
	if(settings["HD"]){
		// Split if a bullet screen is active for Dante
		if(current.bulletScreenHD != 0 && old.bulletScreenHD == 0){
			vars.bulletSplit = 1;
			return true;
		}
		
		// Split if new level starts
		if(current.levelHD > old.levelHD && vars.bulletSplit == 0){
			return true;
		}
	}
	
	// Settings for DMC3SE
	if(settings["SE"]){
		// Split if a bullet screen is active for Dante
		if(current.bulletScreen != 0 && old.bulletScreen == 0){
			vars.bulletSplit = 1;
			return true;
		}
	
		// Split if new level starts
		if(current.level > old.level && vars.bulletSplit == 0){
			return true;
		}
		
		// Split if the final boss is killed
        if(current.roomID == 411 && current.level == 20 && current.bossHealthBar > 1000000){
            switch((int)current.costumeSelected){
                case 256: return (current.vHealth1 == 0 && old.vHealth1 > 100000000) || (current.dHealth1 == 0 && old.dHealth1 > 100000000);
                case 262: return current.vHealth1 == 0 && old.vHealth1 > 100000000;
                case 257: return (current.vHealth2 == 0 && old.vHealth2 > 100000000) || (current.dHealth2 == 0 && old.dHealth2 > 100000000);
                case 258: return current.dHealth1 == 0 && old.dHealth1 > 100000000;
                case 259: return (current.vHealth3 == 0 && old.vHealth3 > 100000000) || (current.dHealth3 == 0 && old.dHealth3 > 100000000);
                case 260: return (current.vHealth4 == 0 && old.vHealth4 > 100000000) || (current.dHealth3 == 0 && old.dHealth3 > 100000000);
                case 261: return current.vHealth5 == 0 && old.vHealth5 > 100000000;
                case 263: return current.vHealth5 == 0 && old.vHealth5 > 100000000;
            }
        }
	
	}

    if(settings["DS"]){
        //Chapter 3
        if((current.roomID == 3 && old.roomID == 2 && vars.split == 0)
        ||
        (current.roomID == 4 && old.roomID == 3 && vars.split == 1)
        ||
        (current.roomID == 5 && old.roomID == 4 && vars.split == 2)
        ||
        (current.roomID == 6 && old.roomID == 5 && vars.split == 3)
        ||
        //Chapter 4
        (current.roomID == 101 && old.roomID == 100 && vars.split == 4)
        ||
        (current.roomID == 102 && old.roomID == 101 && vars.split == 5)
        ||
        (current.roomID == 103 && old.roomID == 102 && vars.split == 6)
        ||
        (current.roomID == 110 && old.roomID == 103 && vars.split == 7)
        ||
        (current.roomID == 100 && old.roomID == 110 && vars.split == 8)
        ||
        (current.roomID == 112 && old.roomID == 100 && vars.split == 9)
        ||
        (current.roomID == 104 && old.roomID == 112 && vars.split == 10)
        ||
        (current.roomID == 112 && old.roomID == 104 && vars.split == 11)
        ||
        (current.roomID == 111 && old.roomID == 112 && vars.split == 12)
        ||
        (current.roomID == 110 && old.roomID == 111 && vars.split == 13)
        ||
        //Chapter 5
        (current.roomID == 422 && old.roomID == 111 && vars.split == 14)
        ||
        (current.roomID == 111 && old.roomID == 422 && vars.split == 15)
        ||
        (current.roomID == 112 && old.roomID == 111 && vars.split == 16)
        ||
        (current.roomID == 100 && old.roomID == 112 && vars.split == 17)
        ||
        (current.roomID == 101 && old.roomID == 100 && vars.split == 18)
        ||
        (current.roomID == 102 && old.roomID == 101 && vars.split == 19)
        ||
        (current.roomID == 101 && old.roomID == 102 && vars.split == 20)
        ||
        (current.roomID == 100 && old.roomID == 101 && vars.split == 21)
        ||
        (current.roomID == 112 && old.roomID == 100 && vars.split == 22)
        ||
        (current.roomID == 113 && old.roomID == 112 && vars.split == 23)
        ||
        (current.roomID == 120 && old.roomID == 113 && vars.split == 24)
        ||
        (current.roomID == 121 && old.roomID == 120 && vars.split == 25)
        ||
        //Chapter 6
        (current.roomID == 123 && old.roomID == 122 && vars.split == 26)
        ||
        ((current.roomID == 124 && old.roomID == 123 || current.roomID == 125 && old.roomID == 123 || current.roomID == 126 && old.roomID == 123) && vars.split == 27)
        ||
        ((old.roomID == 124 && current.roomID == 123 || old.roomID == 125 && current.roomID == 123 || old.roomID == 126 && current.roomID == 123) && vars.split == 28)
        ||
        ((current.roomID == 124 && old.roomID == 123 || current.roomID == 125 && old.roomID == 123 || current.roomID == 126 && old.roomID == 123) && vars.split == 29)
        ||
        ((old.roomID == 124 && current.roomID == 123 || old.roomID == 125 && current.roomID == 123 || old.roomID == 126 && current.roomID == 123) && vars.split == 30)
        ||
        (current.roomID == 122 && old.roomID == 123 && vars.split == 31)
        ||
        (current.roomID == 127 && old.roomID == 122 && vars.split == 32)
        ||
        //Chapter 7
        (current.roomID == 114 && old.roomID == 127 && vars.split == 33)
        ||
        (current.roomID == 115 && old.roomID == 114 && vars.split == 34)
        ||
        (current.roomID == 114 && old.roomID == 115 && vars.split == 35)
        ||
        (current.roomID == 134 && old.roomID == 114 && vars.split == 36)
        ||
        (current.roomID == 135 && old.roomID == 134 && vars.split == 37)
        ||
        (current.roomID == 136 && old.roomID == 135 && vars.split == 38)
        ||
        (current.roomID == 137 && old.roomID == 136 && vars.split == 39)
        ||
        (current.roomID == 100 && old.roomID == 137 && vars.split == 40)
        ||
        (current.roomID == 101 && old.roomID == 100 && vars.split == 41)
        ||
        (current.roomID == 105 && old.roomID == 101 && vars.split == 42)
        ||
        (current.roomID == 101 && old.roomID == 105 && vars.split == 43)
        ||
        (current.roomID == 100 && old.roomID == 101 && vars.split == 44)
        ||
        (current.roomID == 137 && old.roomID == 100 && vars.split == 45)
        ||
        (current.roomID == 136 && old.roomID == 137 && vars.split == 46)
        ||
        (current.roomID == 135 && old.roomID == 136 && vars.split == 47)
        ||
        (current.roomID == 138 && old.roomID == 135 && vars.split == 48)
        ||
        (current.roomID == 142 && old.roomID == 138 && vars.split == 49)
        ||
        (current.roomID == 144 && old.roomID == 142 && vars.split == 50)
        ||
        //Chapter 8
        (current.roomID == 301 && old.roomID == 300 && vars.split == 51)
        ||
        (current.roomID == 302 && old.roomID == 301 && vars.split == 52)
        ||
        (current.roomID == 303 && old.roomID == 302 && vars.split == 53)
        ||
        (current.roomID == 304 && old.roomID == 303 && vars.split == 54)
        ||
        (current.roomID == 305 && old.roomID == 304 && vars.split == 55)
        ||
        (current.roomID == 306 && old.roomID == 305 && vars.split == 56)
        ||
        (current.roomID == 307 && old.roomID == 306 && vars.split == 57)
        ||
        (current.roomID == 308 && old.roomID == 307 && vars.split == 58)
        ||
        (current.roomID == 309 && old.roomID == 308 && vars.split == 59)
        ||
        (current.roomID == 302 && old.roomID == 309 && vars.split == 60)
        ||
        //Chapter 9
        (current.roomID == 202 && old.roomID == 201 && vars.split == 61)
        ||
        (current.roomID == 203 && old.roomID == 202 && vars.split == 62)
        ||
        (current.roomID == 204 && old.roomID == 203 && vars.split == 63)
        ||
        (current.roomID == 205 && old.roomID == 204 && vars.split == 64)
        ||
        (current.roomID == 206 && old.roomID == 205 && vars.split == 65)
        ||
        (current.roomID == 207 && old.roomID == 206 && vars.split == 66)
        ||
        (current.roomID == 208 && old.roomID == 207 && vars.split == 67)
        ||
        (current.roomID == 207 && old.roomID == 208 && vars.split == 68)
        ||
        (current.roomID == 206 && old.roomID == 207 && vars.split == 69)
        ||
        (current.roomID == 209 && old.roomID == 206 && vars.split == 70)
        ||
        (current.roomID == 210 && old.roomID == 209 && current.level == 9 && vars.split == 71)
        ||
        //Chapter 10
        (current.roomID == 210 && old.roomID == 209 && current.level == 10 && vars.split == 72)
        ||
        (current.roomID == 209 && old.roomID == 210 && vars.split == 73)
        ||
        (current.roomID == 206 && old.roomID == 209 && vars.split == 74)
        ||
        (current.roomID == 205 && old.roomID == 206 && vars.split == 75)
        ||
        (current.roomID == 204 && old.roomID == 205 && vars.split == 76)
        ||
        (current.roomID == 203 && old.roomID == 204 && vars.split == 77)
        ||
        (current.roomID == 202 && old.roomID == 203 && vars.split == 78)
        ||
        (current.roomID == 201 && old.roomID == 202 && vars.split == 79)
        ||
        (current.roomID == 211 && old.roomID == 201 && vars.split == 80)
        ||
        //Chapter 11
        (current.roomID == 213 && old.roomID == 212 && vars.split == 81)
        ||
        (current.roomID == 214 && old.roomID == 213 && vars.split == 82)
        ||
        (current.roomID == 239 && old.roomID == 214 && vars.split == 83)
        ||
        (current.roomID == 216 && old.roomID == 239 && vars.split == 84)
        ||
        (current.roomID == 240 && old.roomID == 216 && vars.split == 85)
        ||
        (current.roomID == 217 && old.roomID == 240 && vars.split == 86)
        ||
    	//Chapter 12
        (current.roomID == 240 && old.roomID == 217 && vars.split == 87)
        ||
        (current.roomID == 216 && old.roomID == 240 && vars.split == 88)
        ||
        (current.roomID == 239 && old.roomID == 216 && vars.split == 89)
        ||
        (current.roomID == 214 && old.roomID == 239 && vars.split == 90)
        ||
        (current.roomID == 213 && old.roomID == 214 && vars.split == 91)
        ||
        (current.roomID == 212 && old.roomID == 213 && vars.split == 92)
        ||
        (current.roomID == 211 && old.roomID == 212 && vars.split == 93)
        ||
        (current.roomID == 201 && old.roomID == 211 && vars.split == 94)
        ||
        (current.roomID == 218 && old.roomID == 201 && vars.split == 95)
        ||
        (current.roomID == 228 && old.roomID == 218 && vars.split == 96)
        ||
        //Chapter 13
        (current.roomID == 230 && old.roomID == 229 && vars.split == 97)
        ||
        (current.roomID == 241 && old.roomID == 230 && vars.split == 98)
        ||
        (current.roomID == 233 && old.roomID == 241 && vars.split == 99)
        ||
        (current.roomID == 241 && old.roomID == 233 && vars.split == 100)
        ||
        (current.roomID == 232 && old.roomID == 241 && vars.split == 101)
        ||
        (current.roomID == 234 && old.roomID == 232 && vars.split == 102)
        ||
        //Chapter 14
        (current.roomID == 235 && old.roomID == 237 && vars.split == 103)
        ||
        (current.roomID == 225 && old.roomID == 235 && vars.split == 104)
        ||
        (current.roomID == 231 && old.roomID == 225 && vars.split == 105)
        ||
        (current.roomID == 233 && old.roomID == 231 && vars.split == 106)
        ||
        (current.roomID == 214 && old.roomID == 233 && vars.split == 107)
        ||
        (current.roomID == 239 && old.roomID == 214 && vars.split == 108)
        ||
        (current.roomID == 216 && old.roomID == 239 && vars.split == 109)
        ||
        (current.roomID == 240 && old.roomID == 216 && vars.split == 110)
        ||
        (current.roomID == 236 && old.roomID == 240 && vars.split == 111)
        ||
        (current.roomID == 221 && old.roomID == 236 && vars.split == 112)
        ||
        (current.roomID == 204 && old.roomID == 221 && vars.split == 113)
        ||
        (current.roomID == 7 && old.roomID == 204 && vars.split == 114)
        ||
        (current.roomID == 8 && old.roomID == 7 && vars.split == 115)
        ||
        //Chapter 15
        (current.roomID == 202 && old.roomID == 222 && vars.split == 116)
        ||
        (current.roomID == 219 && old.roomID == 202 && vars.split == 117)
        ||
        (current.roomID == 200 && old.roomID == 219 && vars.split == 118)
        ||
        (current.roomID == 219 && old.roomID == 200 && vars.split == 119)
        ||
        (current.roomID == 202 && old.roomID == 219 && vars.split == 120)
        ||
        (current.roomID == 226 && old.roomID == 202 && vars.split == 121)
        ||
        (current.roomID == 224 && old.roomID == 226 && vars.split == 122)
        ||
        (current.roomID == 226 && old.roomID == 224 && vars.split == 123)
        ||
        (current.roomID == 227 && old.roomID == 226 && vars.split == 124)
        ||
        (current.roomID == 208 && old.roomID == 227 && vars.split == 125)
        ||
        (current.roomID == 227 && old.roomID == 208 && vars.split == 126)
        ||
        (current.roomID == 212 && old.roomID == 227 && vars.split == 127)
        ||
        (current.roomID == 213 && old.roomID == 212 && vars.split == 128)
        ||
        (current.roomID == 212 && old.roomID == 213 && vars.split == 129)
        ||
        (current.roomID == 202 && old.roomID == 212 && vars.split == 130)
        ||
        (current.roomID == 219 && old.roomID == 202 && vars.split == 131)
        ||
        //Chapter 16
        (current.roomID == 108 && old.roomID == 106 && vars.split == 132)
        ||
        ((current.roomID == 109 && old.roomID == 108 || current.roomID == 102 && old.roomID == 108) && vars.split == 133)
        ||
        ((current.roomID == 108 && old.roomID == 109 || current.roomID == 146 && old.roomID == 102) && vars.split == 134)
        ||
        ((current.roomID == 106 && old.roomID == 108 || current.roomID == 102 && old.roomID == 146) && vars.split == 135)
        ||
        ((current.roomID == 102 && old.roomID == 108 || current.roomID == 108 && old.roomID == 102 || current.roomID == 108 && old.roomID == 106) && vars.split == 136)
        ||
        ((current.roomID == 146 && old.roomID == 102 || current.roomID == 106 && old.roomID == 108 || current.roomID == 102 && old.roomID == 108) && vars.split == 137)
        ||
        ((current.roomID == 102 && old.roomID == 146 || current.roomID == 108 && old.roomID == 106 || current.roomID == 146 && old.roomID == 102) && vars.split == 138)
        ||
        ((current.roomID == 108 && old.roomID == 102 || current.roomID == 109 && old.roomID == 108 || current.roomID == 102 && old.roomID == 146) && vars.split == 139)
        ||
        ((current.roomID == 106 && old.roomID == 108 || current.roomID == 108 && old.roomID == 109 || current.roomID == 108 && old.roomID == 102) && vars.split == 140)
        ||
        (current.roomID == 106 && old.roomID == 108 && vars.split == 141)
        ||
        (current.roomID == 107 && old.roomID == 106 && vars.split == 142)
        ||
        (current.roomID == 118 && old.roomID == 107 && vars.split == 143)
        ||
        (current.roomID == 117 && old.roomID == 118 && vars.split == 144)
        ||
        (current.roomID == 111 && old.roomID == 117 && vars.split == 145)
        ||
        (current.roomID == 116 && old.roomID == 111 && vars.split == 146)
        ||
        (current.roomID == 115 && old.roomID == 116 && vars.split == 147)
        ||
        (current.roomID == 119 && old.roomID == 115 && vars.split == 148)
        ||
        //Chapter 17
        (current.roomID == 128 && old.roomID == 133 && vars.split == 149)
        ||
        (current.roomID == 129 && old.roomID == 128 && vars.split == 150)
        ||
        (current.roomID == 132 && old.roomID == 129 && vars.split == 151)
        ||
        (current.roomID == 131 && old.roomID == 132 && vars.split == 152)
        ||
        (current.roomID == 140 && old.roomID == 131 && vars.split == 153)
        ||
        (current.roomID == 141 && old.roomID == 140 && vars.split == 154)
        ||
        (current.roomID == 138 && old.roomID == 141 && vars.split == 155)
        ||
        (current.roomID == 143 && old.roomID == 138 && vars.split == 156)
        ||
        (current.roomID == 139 && old.roomID == 143 && vars.split == 157)
        ||
        (current.roomID == 143 && old.roomID == 139 && vars.split == 158)
        ||
        //Chapter 18
        (current.roomID == 401 && old.roomID == 400 && vars.split == 159)
        ||
        (current.roomID == 402 && old.roomID == 401 && vars.split == 160)
        ||
        (current.roomID == 403 && old.roomID == 402 && vars.split == 161)
        ||
        ((old.roomID == 403 && current.roomID == 412 || old.roomID == 403 && current.roomID == 414 || old.roomID == 403 && current.roomID == 416) && vars.split == 162)
        ||
        ((current.roomID == 403 && old.roomID == 412 || current.roomID == 403 && old.roomID == 414 || current.roomID == 403 && old.roomID == 416) && vars.split == 163)
        ||
        ((old.roomID == 403 && current.roomID == 412 || old.roomID == 403 && current.roomID == 414 || old.roomID == 403 && current.roomID == 416) && vars.split == 164)
        ||
        ((current.roomID == 403 && old.roomID == 412 || current.roomID == 403 && old.roomID == 414 || current.roomID == 403 && old.roomID == 416) && vars.split == 165)
        ||
        ((old.roomID == 403 && current.roomID == 412 || old.roomID == 403 && current.roomID == 414 || old.roomID == 403 && current.roomID == 416) && vars.split == 166)
        ||
        ((current.roomID == 403 && old.roomID == 412 || current.roomID == 403 && old.roomID == 414 || current.roomID == 403 && old.roomID == 416) && vars.split == 167)
        ||
        //Chapter 19
        (current.roomID == 405 && old.roomID == 406 && vars.split == 168)
        ||
        (current.roomID == 404 && old.roomID == 405 && vars.split == 169)
        ||
        (current.roomID == 403 && old.roomID == 404 && vars.split == 170)
        ||
        (current.roomID == 406 && old.roomID == 403 && vars.split == 171)
        ||
        (current.roomID == 405 && old.roomID == 406 && vars.split == 172)
        ||
        (current.roomID == 408 && old.roomID == 405 && vars.split == 173)
        ||
        (current.roomID == 421 && old.roomID == 408 && vars.split == 174)){
            vars.split++;
            return true;
        }
    }

    if(settings["SEDS"]){
        //Chapter 3
        if((current.roomID == 3 && old.roomID == 2 && vars.split == 0)
        ||
        (current.roomID == 4 && old.roomID == 3 && vars.split == 1)
        ||
        (current.roomID == 5 && old.roomID == 4 && vars.split == 2)
        ||
        (current.roomID == 6 && old.roomID == 5 && vars.split == 3)
        ||
        //Chapter 4
        (current.roomID == 101 && old.roomID == 100 && vars.split == 4)
        ||
        (current.roomID == 102 && old.roomID == 101 && vars.split == 5)
        ||
        (current.roomID == 103 && old.roomID == 102 && vars.split == 6)
        ||
        (current.roomID == 110 && old.roomID == 103 && vars.split == 7)
        ||
        (current.roomID == 100 && old.roomID == 110 && vars.split == 8)
        ||
        (current.roomID == 112 && old.roomID == 100 && vars.split == 9)
        ||
        (current.roomID == 104 && old.roomID == 112 && vars.split == 10)
        ||
        (current.roomID == 112 && old.roomID == 104 && vars.split == 11)
        ||
        (current.roomID == 111 && old.roomID == 112 && vars.split == 12)
        ||
        (current.roomID == 110 && old.roomID == 111 && vars.split == 13)
        ||
        //Chapter 5
        (current.roomID == 422 && old.roomID == 111 && vars.split == 14)
        ||
        (current.roomID == 111 && old.roomID == 422 && vars.split == 15)
        ||
        (current.roomID == 112 && old.roomID == 111 && vars.split == 16)
        ||
        (current.roomID == 100 && old.roomID == 112 && vars.split == 17)
        ||
        (current.roomID == 101 && old.roomID == 100 && vars.split == 18)
        ||
        (current.roomID == 102 && old.roomID == 101 && vars.split == 19)
        ||
        (current.roomID == 101 && old.roomID == 102 && vars.split == 20)
        ||
        (current.roomID == 100 && old.roomID == 101 && vars.split == 21)
        ||
        (current.roomID == 112 && old.roomID == 100 && vars.split == 22)
        ||
        (current.roomID == 113 && old.roomID == 112 && vars.split == 23)
        ||
        (current.roomID == 120 && old.roomID == 113 && vars.split == 24)
        ||
        (current.roomID == 121 && old.roomID == 120 && vars.split == 25)
        ||
        //Chapter 6
        (current.roomID == 123 && old.roomID == 122 && vars.split == 26)
        ||
        ((current.roomID == 124 && old.roomID == 123 || current.roomID == 125 && old.roomID == 123 || current.roomID == 126 && old.roomID == 123) && vars.split == 27)
        ||
        ((old.roomID == 124 && current.roomID == 123 || old.roomID == 125 && current.roomID == 123 || old.roomID == 126 && current.roomID == 123) && vars.split == 28)
        ||
        ((current.roomID == 124 && old.roomID == 123 || current.roomID == 125 && old.roomID == 123 || current.roomID == 126 && old.roomID == 123) && vars.split == 29)
        ||
        ((old.roomID == 124 && current.roomID == 123 || old.roomID == 125 && current.roomID == 123 || old.roomID == 126 && current.roomID == 123) && vars.split == 30)
        ||
        (current.roomID == 122 && old.roomID == 123 && vars.split == 31)
        ||
        (current.roomID == 127 && old.roomID == 122 && vars.split == 32)
        ||
        //Chapter 7
        (current.roomID == 114 && old.roomID == 127 && vars.split == 33)
        ||
        (current.roomID == 115 && old.roomID == 114 && vars.split == 34)
        ||
        (current.roomID == 114 && old.roomID == 115 && vars.split == 35)
        ||
        (current.roomID == 134 && old.roomID == 114 && vars.split == 36)
        ||
        (current.roomID == 135 && old.roomID == 134 && vars.split == 37)
        ||
        (current.roomID == 136 && old.roomID == 135 && vars.split == 38)
        ||
        (current.roomID == 137 && old.roomID == 136 && vars.split == 39)
        ||
        (current.roomID == 100 && old.roomID == 137 && vars.split == 40)
        ||
        (current.roomID == 101 && old.roomID == 100 && vars.split == 41)
        ||
        (current.roomID == 105 && old.roomID == 101 && vars.split == 42)
        ||
        (current.roomID == 101 && old.roomID == 105 && vars.split == 43)
        ||
        (current.roomID == 100 && old.roomID == 101 && vars.split == 44)
        ||
        (current.roomID == 137 && old.roomID == 100 && vars.split == 45)
        ||
        (current.roomID == 136 && old.roomID == 137 && vars.split == 46)
        ||
        (current.roomID == 135 && old.roomID == 136 && vars.split == 47)
        ||
        (current.roomID == 138 && old.roomID == 135 && vars.split == 48)
        ||
        (current.roomID == 142 && old.roomID == 138 && vars.split == 49)
        ||
        (current.roomID == 144 && old.roomID == 142 && vars.split == 50)
        ||
        //Chapter 8
        (current.roomID == 301 && old.roomID == 300 && vars.split == 51)
        ||
        (current.roomID == 302 && old.roomID == 301 && vars.split == 52)
        ||
        (current.roomID == 303 && old.roomID == 302 && vars.split == 53)
        ||
        (current.roomID == 304 && old.roomID == 303 && vars.split == 54)
        ||
        (current.roomID == 305 && old.roomID == 304 && vars.split == 55)
        ||
        (current.roomID == 306 && old.roomID == 305 && vars.split == 56)
        ||
        (current.roomID == 307 && old.roomID == 306 && vars.split == 57)
        ||
        (current.roomID == 308 && old.roomID == 307 && vars.split == 58)
        ||
        (current.roomID == 309 && old.roomID == 308 && vars.split == 59)
        ||
        (current.roomID == 302 && old.roomID == 309 && vars.split == 60)
        ||
        //Chapter 9
        (current.roomID == 202 && old.roomID == 201 && vars.split == 61)
        ||
        (current.roomID == 203 && old.roomID == 202 && vars.split == 62)
        ||
        (current.roomID == 204 && old.roomID == 203 && vars.split == 63)
        ||
        (current.roomID == 205 && old.roomID == 204 && vars.split == 64)
        ||
        (current.roomID == 206 && old.roomID == 205 && vars.split == 65)
        ||
        (current.roomID == 207 && old.roomID == 206 && vars.split == 66)
        ||
        (current.roomID == 208 && old.roomID == 207 && vars.split == 67)
        ||
        (current.roomID == 207 && old.roomID == 208 && vars.split == 68)
        ||
        (current.roomID == 206 && old.roomID == 207 && vars.split == 69)
        ||
        (current.roomID == 209 && old.roomID == 206 && vars.split == 70)
        ||
        (current.roomID == 210 && old.roomID == 209 && current.level == 9 && vars.split == 71)
        ||
        //Chapter 10
        (current.roomID == 210 && old.roomID == 209 && current.level == 10 && vars.split == 72)
        ||
        (current.roomID == 209 && old.roomID == 210 && vars.split == 73)
        ||
        (current.roomID == 206 && old.roomID == 209 && vars.split == 74)
        ||
        (current.roomID == 205 && old.roomID == 206 && vars.split == 75)
        ||
        (current.roomID == 204 && old.roomID == 205 && vars.split == 76)
        ||
        (current.roomID == 203 && old.roomID == 204 && vars.split == 77)
        ||
        (current.roomID == 202 && old.roomID == 203 && vars.split == 78)
        ||
        (current.roomID == 201 && old.roomID == 202 && vars.split == 79)
        ||
        (current.roomID == 211 && old.roomID == 201 && vars.split == 80)
        ||
        //Chapter 11
        (current.roomID == 213 && old.roomID == 212 && vars.split == 81)
        ||
        (current.roomID == 214 && old.roomID == 213 && vars.split == 82)
        ||
        (current.roomID == 239 && old.roomID == 214 && vars.split == 83)
        ||
        (current.roomID == 216 && old.roomID == 239 && vars.split == 84)
        ||
        (current.roomID == 240 && old.roomID == 216 && vars.split == 85)
        ||
        (current.roomID == 217 && old.roomID == 240 && vars.split == 86)
        ||
    	//Chapter 12
        (current.roomID == 240 && old.roomID == 217 && vars.split == 87)
        ||
        (current.roomID == 216 && old.roomID == 240 && vars.split == 88)
        ||
        (current.roomID == 239 && old.roomID == 216 && vars.split == 89)
        ||
        (current.roomID == 214 && old.roomID == 239 && vars.split == 90)
        ||
        (current.roomID == 213 && old.roomID == 214 && vars.split == 91)
        ||
        (current.roomID == 212 && old.roomID == 213 && vars.split == 92)
        ||
        (current.roomID == 211 && old.roomID == 212 && vars.split == 93)
        ||
        (current.roomID == 201 && old.roomID == 211 && vars.split == 94)
        ||
        (current.roomID == 218 && old.roomID == 201 && vars.split == 95)
        ||
        (current.roomID == 228 && old.roomID == 218 && vars.split == 96)
        ||
        //Chapter 13
        (current.roomID == 230 && old.roomID == 229 && vars.split == 97)
        ||
        (current.roomID == 241 && old.roomID == 230 && vars.split == 98)
        ||
        (current.roomID == 233 && old.roomID == 241 && vars.split == 99)
        ||
        (current.roomID == 241 && old.roomID == 233 && vars.split == 100)
        ||
        (current.roomID == 232 && old.roomID == 241 && vars.split == 101)
        ||
        (current.roomID == 234 && old.roomID == 232 && vars.split == 102)
        ||
        //Chapter 14
        (current.roomID == 235 && old.roomID == 237 && vars.split == 103)
        ||
        (current.roomID == 225 && old.roomID == 235 && vars.split == 104)
        ||
        (current.roomID == 231 && old.roomID == 225 && vars.split == 105)
        ||
        (current.roomID == 233 && old.roomID == 231 && vars.split == 106)
        ||
        (current.roomID == 214 && old.roomID == 233 && vars.split == 107)
        ||
        (current.roomID == 239 && old.roomID == 214 && vars.split == 108)
        ||
        (current.roomID == 216 && old.roomID == 239 && vars.split == 109)
        ||
        (current.roomID == 240 && old.roomID == 216 && vars.split == 110)
        ||
        (current.roomID == 236 && old.roomID == 240 && vars.split == 111)
        ||
        (current.roomID == 221 && old.roomID == 236 && vars.split == 112)
        ||
        (current.roomID == 204 && old.roomID == 221 && vars.split == 113)
        ||
        (current.roomID == 7 && old.roomID == 204 && vars.split == 114)
        ||
        (current.roomID == 8 && old.roomID == 7 && vars.split == 115)
        ||
        //Chapter 15
        (current.roomID == 202 && old.roomID == 222 && vars.split == 116)
        ||
        (current.roomID == 219 && old.roomID == 202 && vars.split == 117)
        ||
        (current.roomID == 200 && old.roomID == 219 && vars.split == 118)
        ||
        (current.roomID == 219 && old.roomID == 200 && vars.split == 119)
        ||
        (current.roomID == 202 && old.roomID == 219 && vars.split == 120)
        ||
        (current.roomID == 226 && old.roomID == 202 && vars.split == 121)
        ||
        (current.roomID == 224 && old.roomID == 226 && vars.split == 122)
        ||
        (current.roomID == 226 && old.roomID == 224 && vars.split == 123)
        ||
        (current.roomID == 227 && old.roomID == 226 && vars.split == 124)
        ||
        (current.roomID == 208 && old.roomID == 227 && vars.split == 125)
        ||
        (current.roomID == 227 && old.roomID == 208 && vars.split == 126)
        ||
        (current.roomID == 212 && old.roomID == 227 && vars.split == 127)
        ||
        (current.roomID == 213 && old.roomID == 212 && vars.split == 128)
        ||
        (current.roomID == 212 && old.roomID == 213 && vars.split == 129)
        ||
        (current.roomID == 202 && old.roomID == 212 && vars.split == 130)
        ||
        (current.roomID == 219 && old.roomID == 202 && vars.split == 131)
        ||
        //Chapter 16
        (current.roomID == 108 && old.roomID == 106 && vars.split == 132)
        ||
        ((current.roomID == 109 && old.roomID == 108 || current.roomID == 102 && old.roomID == 108) && vars.split == 133)
        ||
        ((current.roomID == 108 && old.roomID == 109 || current.roomID == 146 && old.roomID == 102) && vars.split == 134)
        ||
        ((current.roomID == 106 && old.roomID == 108 || current.roomID == 102 && old.roomID == 146) && vars.split == 135)
        ||
        ((current.roomID == 102 && old.roomID == 108 || current.roomID == 108 && old.roomID == 102 || current.roomID == 108 && old.roomID == 106) && vars.split == 136)
        ||
        ((current.roomID == 146 && old.roomID == 102 || current.roomID == 106 && old.roomID == 108 || current.roomID == 102 && old.roomID == 108) && vars.split == 137)
        ||
        ((current.roomID == 102 && old.roomID == 146 || current.roomID == 108 && old.roomID == 106 || current.roomID == 146 && old.roomID == 102) && vars.split == 138)
        ||
        ((current.roomID == 108 && old.roomID == 102 || current.roomID == 109 && old.roomID == 108 || current.roomID == 102 && old.roomID == 146) && vars.split == 139)
        ||
        ((current.roomID == 106 && old.roomID == 108 || current.roomID == 108 && old.roomID == 109 || current.roomID == 108 && old.roomID == 102) && vars.split == 140)
        ||
        (current.roomID == 106 && old.roomID == 108 && vars.split == 141)
        ||
        (current.roomID == 107 && old.roomID == 106 && vars.split == 142)
        ||
        (current.roomID == 118 && old.roomID == 107 && vars.split == 143)
        ||
        (current.roomID == 117 && old.roomID == 118 && vars.split == 144)
        ||
        (current.roomID == 111 && old.roomID == 117 && vars.split == 145)
        ||
        (current.roomID == 116 && old.roomID == 111 && vars.split == 146)
        ||
        (current.roomID == 115 && old.roomID == 116 && vars.split == 147)
        ||
        (current.roomID == 119 && old.roomID == 115 && vars.split == 148)
        ||
        //Chapter 17
        (current.roomID == 128 && old.roomID == 133 && vars.split == 149)
        ||
        (current.roomID == 129 && old.roomID == 128 && vars.split == 150)
        ||
        (current.roomID == 132 && old.roomID == 129 && vars.split == 151)
        ||
        (current.roomID == 131 && old.roomID == 132 && vars.split == 152)
        ||
        (current.roomID == 140 && old.roomID == 131 && vars.split == 153)
        ||
        (current.roomID == 141 && old.roomID == 140 && vars.split == 154)
        ||
        (current.roomID == 138 && old.roomID == 141 && vars.split == 155)
        ||
        (current.roomID == 143 && old.roomID == 138 && vars.split == 156)
        ||
        (current.roomID == 139 && old.roomID == 143 && vars.split == 157)
        ||
        (current.roomID == 143 && old.roomID == 139 && vars.split == 158)
        ||
        //Chapter 18
        (current.roomID == 401 && old.roomID == 400 && vars.split == 159)
        ||
        (current.roomID == 402 && old.roomID == 401 && vars.split == 160)
        ||
        (current.roomID == 403 && old.roomID == 402 && vars.split == 161)
        ||
        ((old.roomID == 403 && current.roomID == 412 || old.roomID == 403 && current.roomID == 414 || old.roomID == 403 && current.roomID == 416) && vars.split == 162)
        ||
        ((current.roomID == 403 && old.roomID == 412 || current.roomID == 403 && old.roomID == 414 || current.roomID == 403 && old.roomID == 416) && vars.split == 163)
        ||
        ((old.roomID == 403 && current.roomID == 412 || old.roomID == 403 && current.roomID == 414 || old.roomID == 403 && current.roomID == 416) && vars.split == 164)
        ||
        ((current.roomID == 403 && old.roomID == 412 || current.roomID == 403 && old.roomID == 414 || current.roomID == 403 && old.roomID == 416) && vars.split == 165)
        ||
        ((old.roomID == 403 && current.roomID == 412 || old.roomID == 403 && current.roomID == 414 || old.roomID == 403 && current.roomID == 416) && vars.split == 166)
        ||
        ((current.roomID == 403 && old.roomID == 412 || current.roomID == 403 && old.roomID == 414 || current.roomID == 403 && old.roomID == 416) && vars.split == 167)
        ||
        //Chapter 19
        (current.roomID == 405 && old.roomID == 406 && vars.split == 168)
        ||
        (current.roomID == 404 && old.roomID == 405 && vars.split == 169)
        ||
        (current.roomID == 403 && old.roomID == 404 && vars.split == 170)
        ||
        (current.roomID == 406 && old.roomID == 403 && vars.split == 171)
        ||
        (current.roomID == 405 && old.roomID == 406 && vars.split == 172)
        ||
        (current.roomID == 408 && old.roomID == 405 && vars.split == 173)
        ||
        (current.roomID == 421 && old.roomID == 408 && vars.split == 174)){
            vars.split++;
            return true;
        }
    }
}

reset
{
    if((settings["HD"] && (current.menuHD == 1 || current.menuHD == 16777217) && current.NGStartHD == 4 || settings["SE"] && (current.resetNGPlus == 127 && old.resetNGPlus > 0 && current.NGStart == 0) || settings["SE"] && (current.resetNGPlus > 20935536 && current.resetNGPlus < 4000000000 && old.resetNGPlus == 0))){
        return true;
    }
}

isLoading
{
    
	// Loadremover for door loads and menu for HD
	if(settings["HD"] && settings["LoadRemover"]){
		if(current.LS == 1){
			return true;
		}
		else{
			return false;
		}
	}
	
	
	// Loadremover for door loads and menu for SE
	if(settings["SE"] && settings["LoadRemover"]){
		if(current.gameState == 1){
			return true;
		}
		else{
			return false;
		}
	}
}
