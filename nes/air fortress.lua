require "x_functions";

if not x_requires then
	-- Sanity check. If they require a newer version, let them know.
	timer	= 1;
	while (true) do
		timer = timer + 1;
		for i = 0, 32 do
			gui.drawbox( 6, 28 + i, 250, 92 - i, "#000000");
		end;
		gui.text( 10, 32, string.format("This Lua script requires the x_functions library."));
		gui.text( 53, 42, string.format("It appears you do not have it."));
		gui.text( 39, 58, "Please get the x_functions library at");
		gui.text( 14, 69, "http://xkeeper.shacknet.nu/");
		gui.text(114, 78, "emu/nes/lua/x_functions.lua");

		warningboxcolor	= string.format("%02X", math.floor(math.abs(30 - math.fmod(timer, 60)) / 30 * 0xFF));
		gui.drawbox(7, 29, 249, 91, "#ff" .. warningboxcolor .. warningboxcolor);

		FCEU.frameadvance();
	end;

else
	x_requires(1);
end;


player	= {};
inpt	= {};
inptold	= {};

while true do

	player['en']	= memory.readword(0x65E7);
	player['enmax']	= memory.readword(0x65E9);


	--lifebar(  77, 209, 100, 4, player['hp'], player['mhp'], "#ffaaaa", "#990000", "#000000", "#ff0000");

	lifebar(  100,  8, 100, 4, player['en'], player['enmax'], "red", "#880000", "black", "white");
	gui.text(100, 16, string.format("%4d/%4d", player['en'], player['enmax']));


	emu.frameadvance();

end