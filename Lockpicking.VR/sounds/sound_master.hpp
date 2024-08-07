
#define M_SOUND(cname,sname,loc,vol,pitch) class cname {\
	name=sname;\
	sound[]={loc,vol,pitch};\
	titles[]={};\
};

// Template: class name, sound name, file, volume, pitch, max distance
// Template M_SOUND(name, "name", "\sounds\soundfile.ogg", 1, 1)

class CfgSounds
{

	sounds[] = {}; // OFP required it filled, now it can be empty or absent depending on the game's version

	M_SOUND(lockpick_jiggle, "lockpick_jiggle", "\sounds\lockpicking\lockpick_jiggle.ogg", 3, 1)
	M_SOUND(lockpick_rattle, "lockpick_rattle", "\sounds\lockpicking\lockpick_rattle.ogg", 3, 1)
	M_SOUND(lockpick_inner_lock_rotate, "lockpick_inner_lock_rotate", "\sounds\lockpicking\inner_lock_rotate.ogg", 3, 1)
	M_SOUND(lockpick_break, "lockpick_break", "\sounds\lockpicking\lockpick_break.ogg", 3, 1)
	M_SOUND(lockpick_break_chance, "lockpick_break_chance", "\sounds\lockpicking\lockpick_break_chance.ogg", 0.5, 1)
	M_SOUND(unlock, "unlock", "\sounds\generic\unlock.ogg", 3, 1)

};
