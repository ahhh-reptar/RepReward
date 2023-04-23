# RepReward
RepReward by jayd (acquired from https://cdn.wowinterface.com/downloads/info22302-RepReward.html), backported by me to work with 3.3.5

# Original description by jayd

Lightweight addon to display reputation rewards for quests. When player opens a quest (at a quest giver or from the quest log) the addon adds the factions and reputation rewards associated with that quest to the quest detail frame.

The addon has a very small footprint. It does not use any local data repository. When the player opens a quest, the addon queries the game for the amount of reputation offered.

The addon calculates reputation bonus based on race (humans have a racial reputation bonus), reputation buffs (i.e. Darkmoon Top Hat, etc.), and MoP Grand Commendations.

Example of addon use:

The addon helps players identify quests they want to save until they have reached a certain reputation level with a faction. For example, the Sporeggar faction has a few turn ins that give reputation only until Friendly. However completing quests for them will give reputation all the way to Exalted. An effective way to reach exalted with them is to do the turn ins first and save the quests until the player has reached Friendly with them.

# Changelog
-- Removed code surrounding guild reputation and it seemed to make it work correctly.  Reduced TOC version.
