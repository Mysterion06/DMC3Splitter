/***************************** Created by Austin 'Auddy' Davenport ******************************************/
/******************************* Credits: Mysterion_06_ & Hies *********************************************/
/***************** Devil May Cry 3: Special Editon / HD Collection - Full Game Timer **********************/

state("dmc3")
{
    int bulletScreen:        0xCF2718;                                                   // Bullet screens at the end of missions
    int level:               0xC8F250;                                                   // Level number
    int mainMenuHD:          0xC9DDC4;                                                   // The main menu screen
    int menuTransitionHD:    0xC0CBB0;                                                   // Main menu transitions
    int NGStartHD:           0x5CF9F0;                                                   // New Game start after hitting Gold on the menu
    int plusStartHD:         0x5D95DC;                                                   // New Game+ start on mission select
    int roomID:              0xC8F258;                                                   // Current Room ID
    int isLoading:           0xCEF8E0;                                                   // The game state, 0 normally, 1 when paused/entering new rooms
    int menuHD:              0xCF2680, 0xD8, 0x110, 0xC0, 0x2F8, 0xD0;                   // When in the main menu
    int ngPlusReset:         0xC90E50, 0xD4;                                             // Used to reset for NG+
    int NGStartGY:           0xD6E000;                                                   // Detects when gold/yellow is selected for NG
    int killCount:           0xC90DF8, 0x110;                                             // In game kill counter
}

state("dmc3se")
{
    int bulletScreen:        0x205CF14;           // Bullet screens at the end of missions
    int level:               0x381494;            // Level number
    int isLoading:           0x205BCB8;           // The game state, 0 normally, 1 when paused/entering new rooms
    int NGStart:             0x70D2DC;            // New Game start after hitting Gold on the menu
    int plusStart:           0x188EDB4;           // New Game+ start on mission select
    int roomID:              0x2D3A74, 0x16C;     // Current Room ID               
    int resetNGPlus:         0x76EB30;            // Used to reset when in Chapter/difficulty selection
    int resetNG:             0x188EDC8;           // Used to reset for NG
    int killCount:           0x838B0C;            // In game kill counter
}

start
{
    // The initial timer start logic for NG and NG+ in both HD and SE.
    // It uses some ingame menu values to detect when the run begins
    // which is at gold/yellow selection for NG, and at the level/easy automatic off on NG+
    if(settings["HD"]){
        // NG
        if(current.NGStartGY == 44100 && old.NGStartGY == 22050 && current.level == 1){
            vars.bulletSplit = 0;
            vars.split = 0;
            vars.killCount = 0;
            return true;
        }
        
        // NG+
        if(current.plusStartHD == 344 && old.plusStartHD == 272 && current.mainMenuHD == 0 && current.menuTransitionHD != 37476 && current.level == 1){
            vars.bulletSplit = 0;
            vars.split = 0;
            vars.killCount = 0;
            return true;
        }
    }
    
    if(settings["SE"]){
        // NG
        if(current.NGStart == 7 && old.NGStart == 0 && current.level == 1){
            vars.bulletSplit = 0;
            vars.split = 0;
            vars.killCount = 0;
            return true;
        }

        // NG+
        if(current.plusStart == 1 && old.plusStart == 0){
            vars.bulletSplit = 0;
            vars.split = 0;
            vars.killCount = 0;
            return true;
        }
    }
}


split
{
    // Split if a bulletscreen is active
    if(current.bulletScreen != 0 && old.bulletScreen == 0){
        vars.bulletSplit = 1;
        return true;
    }

    // Split if the level increases
    if(current.level > old.level && vars.bulletSplit == 0)
        return true;
    
    // Final split for when Vante/Dante is killed on M20
    if(current.roomID == 411 && current.level == 20)
        return current.killCount == 1 && old.killCount == 0;

    // Split if the new room entered is found in the list of tuples below
    if(settings["DS"] && vars.doorSplit.Contains(Tuple.Create(current.roomID, old.roomID, current.level, vars.split))){
        vars.split++;
        return true;
    }
}

reset
{
    // The resetters for HD/SE
    if(settings["HD"]){
        if((current.menuHD == 1 || current.menuHD == 16777217) && current.NGStartHD == 4) return true;
        if(settings["NG+HD"] && current.ngPlusReset == 131 && current.plusStartHD == 272) return true;
    }
    if(settings["SE"]){
        if(current.resetNG == 127 && current.resetNG > 0 && current.NGStart == 0) return true;
        if(settings["NG+"] && current.resetNGPlus == 37 && current.plusStart == 0 && current.NGStart == 0) return true;
    }
}

isLoading
{
    // The load removers for HD/SE
    // Removes loads when entering doors and in the pause menu
    if((settings["HD"] || settings["SE"]) && settings["LoadRemover"])
        return current.isLoading == 1;
}

update
{
    // Displays kill counter in livesplit
    if(settings["KC"] && current.killCount > old.killCount && current.killCount < 127)
        vars.killCount = vars.killCount + (current.killCount - old.killCount);
}

init
{
    vars.bulletSplit = 0;
    vars.split = 0;
    vars.killCount = 0;

    // List of tuples for the doorsplit logic
    // tuples are comprised of current.roomID, old.roomID, current.level, vars.split
    // in order. Something to note is the vars.split is sometimes repeated for variations of different
    // rooms. See M6 for example.
    if(settings["DS"]){
        vars.doorSplit = new List<Tuple<int, int, int, int>>{
            // M3
            Tuple.Create(3, 2, 3, 0),
            Tuple.Create(4, 3, 3, 1),
            Tuple.Create(5, 4, 3, 2),
            Tuple.Create(6, 5, 3, 3),
            // M4
            Tuple.Create(101, 100, 4, 4),
            Tuple.Create(102, 101, 4, 5),
            Tuple.Create(103, 102, 4, 6),
            Tuple.Create(110, 103, 4, 7),
            Tuple.Create(100, 110, 4, 8),
            Tuple.Create(112, 100, 4, 9),
            Tuple.Create(104, 112, 4, 10),
            Tuple.Create(112, 104, 4, 11),
            Tuple.Create(111, 112, 4, 12),
            Tuple.Create(110, 111, 4, 13),
            // M5
            Tuple.Create(422, 111, 5, 14),
            Tuple.Create(111, 422, 5, 15),
            Tuple.Create(112, 111, 5, 16),
            Tuple.Create(100, 112, 5, 17),
            Tuple.Create(101, 100, 5, 18),
            Tuple.Create(102, 101, 5, 19),
            Tuple.Create(101, 102, 5, 20),
            Tuple.Create(100, 101, 5, 21),
            Tuple.Create(112, 100, 5, 22),
            Tuple.Create(113, 112, 5, 23),
            Tuple.Create(120, 113, 5, 24),
            Tuple.Create(121, 120, 5, 25),
            // M6
            Tuple.Create(123, 122, 6, 26),
            Tuple.Create(124, 123, 6, 27),
            Tuple.Create(125, 123, 6, 27),
            Tuple.Create(126, 123, 6, 27),
            Tuple.Create(123, 124, 6, 28),
            Tuple.Create(123, 125, 6, 28),
            Tuple.Create(123, 126, 6, 28),
            Tuple.Create(124, 123, 6, 29),
            Tuple.Create(125, 123, 6, 29),
            Tuple.Create(126, 123, 6, 29),
            Tuple.Create(123, 124, 6, 30),
            Tuple.Create(123, 125, 6, 30),
            Tuple.Create(123, 126, 6, 30),
            Tuple.Create(122, 123, 6, 31),
            Tuple.Create(127, 122, 6, 32),
            // M7
            Tuple.Create(114, 127, 7, 33),
            Tuple.Create(115, 114, 7, 34),
            Tuple.Create(114, 115, 7, 35),
            Tuple.Create(134, 114, 7, 36),
            Tuple.Create(135, 134, 7, 37),
            Tuple.Create(136, 135, 7, 38),
            Tuple.Create(137, 136, 7, 39),
            Tuple.Create(100, 137, 7, 40),
            Tuple.Create(101, 100, 7, 41),
            Tuple.Create(105, 101, 7, 42),
            Tuple.Create(101, 105, 7, 43),
            Tuple.Create(100, 101, 7, 44),
            Tuple.Create(137, 100, 7, 45),
            Tuple.Create(136, 137, 7, 46),
            Tuple.Create(135, 136, 7, 47),
            Tuple.Create(138, 135, 7, 48),
            Tuple.Create(142, 138, 7, 49),
            Tuple.Create(144, 142, 7, 50),
            // M8
            Tuple.Create(301, 300, 8, 51),
            Tuple.Create(302, 301, 8, 52),
            Tuple.Create(303, 302, 8, 53),
            Tuple.Create(304, 303, 8, 54),
            Tuple.Create(305, 304, 8, 55),
            Tuple.Create(306, 305, 8, 56),
            Tuple.Create(307, 306, 8, 57),
            Tuple.Create(308, 307, 8, 58),
            Tuple.Create(309, 308, 8, 59),
            Tuple.Create(302, 309, 8, 60),
            // M9
            Tuple.Create(202, 201, 9, 61),
            Tuple.Create(203, 202, 9, 62),
            Tuple.Create(204, 203, 9, 63),
            Tuple.Create(205, 204, 9, 64),
            Tuple.Create(206, 205, 9, 65),
            Tuple.Create(207, 206, 9, 66),
            Tuple.Create(208, 207, 9, 67),
            Tuple.Create(207, 208, 9, 68),
            Tuple.Create(206, 207, 9, 69),
            Tuple.Create(209, 206, 9, 70),
            Tuple.Create(210, 209, 9, 71),
            // M10
            Tuple.Create(210, 209, 10, 72),
            Tuple.Create(209, 210, 10, 73),
            Tuple.Create(206, 209, 10, 74),
            Tuple.Create(205, 206, 10, 75),
            Tuple.Create(204, 205, 10, 76),
            Tuple.Create(203, 204, 10, 77),
            Tuple.Create(202, 203, 10, 78),
            Tuple.Create(201, 202, 10, 79),
            Tuple.Create(211, 201, 10, 80),
            // M11
            Tuple.Create(213, 212, 11, 81),
            Tuple.Create(214, 213, 11, 82),
            Tuple.Create(239, 214, 11, 83),
            Tuple.Create(216, 239, 11, 84),
            Tuple.Create(240, 216, 11, 85),
            Tuple.Create(217, 240, 11, 86),
            // M12
            Tuple.Create(240, 217, 12, 87),
            Tuple.Create(216, 240, 12, 88),
            Tuple.Create(239, 216, 12, 89),
            Tuple.Create(214, 239, 12, 90),
            Tuple.Create(213, 214, 12, 91),
            Tuple.Create(212, 213, 12, 92),
            Tuple.Create(211, 211, 12, 93),
            Tuple.Create(201, 211, 12, 94),
            Tuple.Create(218, 201, 12, 95),
            Tuple.Create(228, 218, 12, 96),
            // M13
            Tuple.Create(230, 229, 13, 97),
            Tuple.Create(241, 230, 13, 98),
            Tuple.Create(233, 241, 13, 99),
            Tuple.Create(241, 233, 13, 100),
            Tuple.Create(232, 241, 13, 101),
            Tuple.Create(234, 232, 13, 102),
            // M14
            Tuple.Create(235, 237, 14, 103),
            Tuple.Create(225, 235, 14, 104),
            Tuple.Create(231, 225, 14, 105),
            Tuple.Create(233, 231, 14, 106),
            Tuple.Create(214, 233, 14, 107),
            Tuple.Create(239, 214, 14, 108),
            Tuple.Create(216, 239, 14, 109),
            Tuple.Create(240, 216, 14, 110),
            Tuple.Create(236, 240, 14, 111),
            Tuple.Create(221, 236, 14, 112),
            Tuple.Create(204, 221, 14, 113),
            Tuple.Create(7, 204, 14, 114),
            Tuple.Create(8, 7, 14, 115),
            // M15
            Tuple.Create(202, 222, 15, 116),
            Tuple.Create(219, 202, 15, 117),
            Tuple.Create(200, 219, 15, 118),
            Tuple.Create(219, 200, 15, 119),
            Tuple.Create(202, 219, 15, 120),
            Tuple.Create(226, 202, 15, 121),
            Tuple.Create(224, 226, 15, 122),
            Tuple.Create(226, 224, 15, 123),
            Tuple.Create(227, 226, 15, 124),
            Tuple.Create(208, 227, 15, 125),
            Tuple.Create(227, 208, 15, 126),
            Tuple.Create(212, 227, 15, 127),
            Tuple.Create(213, 212, 15, 128),
            Tuple.Create(212, 213, 15, 129),
            Tuple.Create(202, 212, 15, 130),
            Tuple.Create(219, 202, 15, 131),
            // M16
            Tuple.Create(108, 106, 16, 132),
            Tuple.Create(109, 108, 16, 133),
            Tuple.Create(102, 108, 16, 133),
            Tuple.Create(108, 109, 16, 134),
            Tuple.Create(146, 102, 16, 134),
            Tuple.Create(106, 108, 16, 135),
            Tuple.Create(102, 146, 16, 135),
            Tuple.Create(102, 108, 16, 136),
            Tuple.Create(108, 102, 16, 136),
            Tuple.Create(108, 106, 16, 136),
            Tuple.Create(146, 102, 16, 137),
            Tuple.Create(106, 108, 16, 137),
            Tuple.Create(102, 108, 16, 137),
            Tuple.Create(102, 146, 16, 138),
            Tuple.Create(108, 106, 16, 138),
            Tuple.Create(146, 102, 16, 138),
            Tuple.Create(108, 102, 16, 139),
            Tuple.Create(109, 108, 16, 139),
            Tuple.Create(102, 146, 16, 139),
            Tuple.Create(106, 108, 16, 140),
            Tuple.Create(108, 109, 16, 140),
            Tuple.Create(108, 102, 16, 140),
            Tuple.Create(106, 108, 16, 141),
            Tuple.Create(107, 106, 16, 142),
            Tuple.Create(118, 107, 16, 143),
            Tuple.Create(117, 118, 16, 144),
            Tuple.Create(111, 117, 16, 145),
            Tuple.Create(116, 111, 16, 146),
            Tuple.Create(115, 116, 16, 147),
            Tuple.Create(119, 115, 16, 148),
            // M17
            Tuple.Create(128, 133, 17, 149),
            Tuple.Create(129, 128, 17, 150),
            Tuple.Create(132, 129, 17, 151),
            Tuple.Create(131, 132, 17, 152),
            Tuple.Create(140, 131, 17, 153), 
            Tuple.Create(141, 140, 17, 154),
            Tuple.Create(138, 141, 17, 155),
            Tuple.Create(143, 138, 17, 156),
            Tuple.Create(139, 143, 17, 157),
            Tuple.Create(143, 139, 17, 158),
            // M18
            Tuple.Create(401, 400, 18, 159),
            Tuple.Create(402, 401, 18, 160),
            Tuple.Create(403, 402, 18, 161),
            Tuple.Create(412, 403, 18, 162),
            Tuple.Create(414, 403, 18, 162),
            Tuple.Create(416, 403, 18, 162),
            Tuple.Create(403, 412, 18, 163),
            Tuple.Create(403, 414, 18, 163),
            Tuple.Create(403, 416, 18, 163),
            Tuple.Create(412, 403, 18, 164),
            Tuple.Create(414, 403, 18, 164),
            Tuple.Create(416, 403, 18, 164),
            Tuple.Create(403, 412, 18, 165),
            Tuple.Create(403, 414, 18, 165),
            Tuple.Create(403, 416, 18, 165),
            Tuple.Create(412, 403, 18, 166),
            Tuple.Create(414, 403, 18, 166),
            Tuple.Create(416, 403, 18, 166),
            Tuple.Create(403, 412, 18, 167),
            Tuple.Create(403, 414, 18, 167),
            Tuple.Create(403, 416, 18, 167),
            // M19
            Tuple.Create(405, 406, 19, 168),
            Tuple.Create(404, 405, 19, 169),
            Tuple.Create(403, 404, 19, 170),
            Tuple.Create(406, 403, 19, 171),
            Tuple.Create(405, 406, 19, 172),
            Tuple.Create(408, 405, 19, 173),
            Tuple.Create(421, 408, 19, 174)
        };
    }
}

startup
{
    // Version
    settings.Add("version", true, "Version");
    settings.SetToolTip("version", "Do not uncheck this box");
    
    // HD
    settings.CurrentDefaultParent = "version";
    settings.Add("HD", true, "HD");
    settings.CurrentDefaultParent = "HD";
    settings.Add("NG+HD", false, "NG+HD");
    settings.SetToolTip("HD", "Check this option if you are running the HD Collection version of DMC3");
    settings.SetToolTip("NG+HD", "Resets at the difficulty selection screen instead of the main menu. Only use for NG+");
    
    // SE
    settings.CurrentDefaultParent = "version";
    settings.Add("SE", false, "SE");
    settings.CurrentDefaultParent = "SE";
    settings.Add("NG+", false, "NG+");
    settings.SetToolTip("SE", "Check this option if you are running the Special Edition version of DMC3");
    settings.SetToolTip("NG+", "Resets at the difficulty selection screen instead of the main menu. Only use for NG+");

    // Options
    settings.CurrentDefaultParent = null;
    settings.Add("options", true, "Options");
    settings.CurrentDefaultParent = "options";
    settings.Add("LoadRemover", true, "Load Remover");
    settings.SetToolTip("LoadRemover", "Check this option if you want to use the Load Remover feature");
    settings.Add("DS", false, "Door Splitter");
    settings.SetToolTip("DS", "Check this option if you want to use the Door Splits feautre");
    settings.Add("KC", false, "Kill Counter");
    settings.SetToolTip("KC", "Display total kills in livesplit. It requires Livesplit.ASLVarViewer (in the main github)");
}
