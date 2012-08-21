version_id	= "b0003";

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
	x_requires(5);

end;


enemyai	= {};

function enemyai.boss1(timer, vars)

	if math.fmod(timer, 60) == 0 then
		balls[z]	= {x = temp, y = 0, xs = math.random(-50, 50) / 100 + (temp - 127) / 127 / 2, ys = math.random(100, 250) / 100, life = 300, c = 2, power = 1};
		z			= z + 1;

	end;


end;
function enemyai.boss1bit(timer, vars)

	if math.fmod(timer, 60) == 0 then
		text(8, 8, "Boss bullet spawn");

	end;


end;





enemytypes	= {};
enemytypes['boss1']	= {
	hp		= 500,
	ai		= enemyai.boss1,
	xs		= 16,
	ys		= 8,
	};

enemytypes['boss1bit']	= {
	hp		= 100,
	ai		= enemyai.boss1bit,
	xs		= 8,
	ys		= 8,
	};



-- mostly useful for centering text onscreen
function centeringhelper()
	line(127, 1, 127, 240, "#ffffff");
	for i = 1, 5 do
		line(127 + i * 20, 1, 127 + i * 20, 240, "#888888");
		line(127 - i * 20, 1, 127 - i * 20, 240, "#888888");
	end;
end;

-- checks if point is within area
function hitbox(b1x1, b1y1, b1x2, b1y2, b2x1, b2y1, b2x2, b2y2)

	boxes	= {
		{
			x	= {b1x1, b1x2},
			y	= {b1y1, b1y2},
			},
		{
			x	= {b2x1, b2x2},
			y	= {b2y1, b2y2},
			},
	};

	hit	= false;

	for xc = 1, 2 do
		for yc = 1, 2 do

			if	(boxes[1]['x'][xc] >= boxes[2]['x'][1]) and
				(boxes[1]['y'][yc] >= boxes[2]['y'][1]) and
				(boxes[1]['x'][xc] <= boxes[2]['x'][2]) and
				(boxes[1]['y'][yc] <= boxes[2]['y'][2]) then

				hit	= true;
			end;
		end;
	end;

	if hit == true then
--		box(b2x1, b2y1, b2x2, b2y2, "#ffffff");
		return true;
	else
--		box(b2x1, b2y1, b2x2, b2y2, "#dd0000");
		return false;
	end;

end;



-- You are my enemy
function doenemies()





end;






-- this function will eventually do bullets
-- it will do all of the various particle effects
-- e.g. enemy bullets (checks playerhitbox), player bullets (checks enemy hitboxes), explosions (does nothing of interest)
function doballs()

	count		= 0;
	local tempballs	= table.clone(balls)
	for k, v in pairs(tempballs) do
		
		v['x']		= v['x'] + v['xs'];
		v['y']		= v['y'] + v['ys'];
		if v['c'] == 0 then
			v['xs']		= v['xs'] * 0.975;
			v['ys']		= v['ys'] * 0.975;
		end;
		if v['c'] == -1 then
			v['ys']		= v['ys'] + 0.05;
		end;
		if gameover and v['c'] > 0 then
			v['life']	= v['life'] - 4;
		else
			v['life']	= v['life'] - 1;
		end;

		if v['x'] < 0 or v['x'] > 254 or v['y'] < 0 or v['y'] > 243 or v['life'] < 0 then
			balls[k]	= nil;
		else
			balls[k]	= v;
--			pixel(v['x'], v['y'], "#FFFFFF");
			colkey		= math.ceil(255 * (5 - math.max(math.min(5, (v['life'] / 15)), 0)) / 5);

			if v['c'] == 1 then
				color	= "#8888ff";
			elseif v['c'] == -1 then
				color	= "#44ccff";
			elseif v['c'] == 2 then
				if v['graze'] then
					color	= "#ff8888";
				else
					color	= "#dd0000";
				end;
				hit		= hitbox(
							v['x'], v['y'], v['x'], v['y'],
							player['x'] - player['xs'], player['y'] - player['ys'], player['x'] + player['xs'], player['y'] + player['ys']
							);
				if hit then
					balls[k]	= nil;
					player['damaged']	= true;
					if v['graze'] then
						player['grazeb']	= player['grazeb'] - 1;
					end;
					player['life']		= math.max(0, player['life'] - v['power']);
					for i = 0, 10 do
						balls[z]	= {x = v['x'], y = v['y'], xs = math.random(-50, 50) / 100, ys = math.random(-50, 50) / 100, life = math.random(15, 30), c = 0};
						z			= z + 1;
					end;
				elseif not v['graze'] then
					hit		= hitbox(
								v['x'], v['y'], v['x'], v['y'],
								player['x'] - (player['xs'] + 3), player['y'] - (player['ys'] + 3), player['x'] + (player['xs'] + 3), player['y'] + (player['ys'] + 3)
								);
					if hit then
						player['grazeb']	= player['grazeb'] + 1;
						balls[k]['graze']	= true;
					end;
				end;

			else
				color	= string.format("#%02X%02X%02X", math.min(math.max(v['life'] / 3 + 60, 0x80), 0xFF), math.min(math.max(v['life'] / 3 + 60, 0x80), 0xFF), math.min(math.max(v['life'] / 3 + 60, 0x80), 0xFF));
--				color	= "#888888";
			end;

			if v['life'] > 45 then 
				box(v['x'], v['y'], v['x'] + 1, v['y'] + 1, color);
			else
				pixel(v['x'], v['y'], color);
			end;
			count		= count + 1;
		end;
	end;

--	lifebar( 2, 140, 249, 10, spower, 400, "#ffffff", "#000044", "#bbbbff");
	return count;
end;


function getready()
	timer	= 0;
	secreti	= 1;
	while not ready do
		doballs();
		--centeringhelper();
		timer		= timer + 1;
		inputlast	= table.clone(inputthis);
		inputthis	= joypad.read(1);
		text(   8,   8, " Engine Test ");
		text(   8,  16, " A: BEGIN ");


		if inputthis['A'] and not inputlast['A'] then
			ready	= true;
		end;
		FCEU.frameadvance();
	end;

	timer	= 0;
	for wait = 0, 60 do
		doballs();
--		centeringhelper();
		timer		= timer + 1;
		if math.fmod(timer, 30) < 15 then
			text(93, 60, " R E A D Y ");
		end;
		lifebar(68, 71, 120, 2, 60 - wait, 60, "#ffffff", "#000000", false, "#dd0000", false);
		box(player['x'] - player['xs'], player['y'] - player['ys'], player['x'] + player['xs'], player['y'] + player['ys'], "#ffffff");
		FCEU.frameadvance();
	end;
end;


function nocpumeter()
	memory.writebyte(0x0016, 0x00);
	memory.writebyte(0x0017, 0x1D);
end;


--memory.register(0x0016, nocpumeter);	-- no scrolling CPU meter
--memory.register(0x0017, nocpumeter); -- no changing the CPU meter line either


function changesong(which)
	memory.writebyte(0x0015, which);
	memory.writebyte(0x0014, 0x01);
end;


debugmode	= true;		-- enables some things like bullet delay display and ship firing.
							-- there's no real reason to leave it disabled if you like fancy graphs :)
inputlast	= {};
inputthis	= {};
bullets		= {};	-- is this even, uh, used?
enemies		= {};
enemyid		= 0;
timer		= 0;
balls		= {};
z			= 0;
score		= 0;
ballrate	= 10;
balltimer	= 10;
ballcount	= 0;
playerlpct	= 0;
gameover	= false;
lastlchange	= 0;
player		= {
	x			= 120;
	y			= 200;
	xs			= 5;
	ys			= 5;
	life		= 25;
	lifem		= 25;
	charge		= 0;
	chargem		= 100;
	power		= 10;
	shottimer	= 0;
	shottimerr	= 6;
	damaged		= false;
	graze		= 0;
	grazeb		= 0;
	};

changesong(10);		-- generic bgm
getready();
timer			= 0;
changesong(3);		-- generic bgm

while not gameover do
--	centeringhelper();

	timer		= timer + 1;

	if timer <= 60 then
		text( 99, 60, "  G O !  ");
	end;
	

	if timer == 1 then
		enemies[enemyid]			= table.clone(enemytypes['boss1']);
		enemies[enemyid]['timer']	= 0;
		

	end;

--	song		= memory.readbyte(0x0015);
--	cpu			= 252 - memory.readbyte(0x0010);

	inputthis	= joypad.read(1);
	if (inputthis['up']) then
		player['y']		= player['y'] - 2;
	elseif (inputthis['down']) then
		player['y']		= player['y'] + 2;
	end;
	if (inputthis['left']) then
		player['x']		= player['x'] - 2;
	elseif (inputthis['right']) then
		player['x']		= player['x'] + 2;
	end;

	player['x']			= math.min(math.max(player['x'], 8), 248);
	player['y']			= math.min(math.max(player['y'], 8), 232);

	if (inputthis['A'] and player['shottimer'] <= 0) and debugmode then
		balls[z]	= {x = player['x'] - 3, y = player['y'] - 2, xs = 0, ys = -6, life = 120, c = 1, power = player['power']};
		balls[z+1]	= {x = player['x'] + 3, y = player['y'] - 2, xs = 0, ys = -6, life = 120, c = 1, power = player['power']};
		z			= z + 2;
		player['shottimer']		= player['shottimerr'];
	else
		player['shottimer']		= player['shottimer'] - 1;
	end;

	if (inputthis['B']) then
		player['shottimerr']	= math.random(0, 32);
	end;





	lastlife		= player['life'];
	doballs();

	if player['damaged'] then
		playerc	= "#dd0000";
		player['damaged']	= false;
		if lastlife > 0 and player['life'] == 0 then
			gameover	= true;
		end;
	else
		playerc	= "#ffffff";
	end;






	player['graze']		= player['graze'] + player['grazeb'];
	player['grazeb']	= 0;
	playerlpctl	= playerlpct;
	playerlpct	= player['life'] / player['lifem'];
	if math.abs(playerlpctl - playerlpct) > 0.0025 then
		playerlpct	= (playerlpct * .05) + (playerlpctl * .95);
	end;

	text(  0, 222, string.format("%8dpts Graze%3d", math.min(99999999, score), player['graze']));
	text(  0, 230, string.format(" %3d/%3d", player['life'], player['lifem']));
	lifebar(47, 231, 200, 4, playerlpct, playerlpct, "#ffffff", "#000000", false, "#000088", false);
	box(player['x'] - player['xs'], player['y'] - player['ys'], player['x'] + player['xs'], player['y'] + player['ys'], playerc);


	FCEU.frameadvance();

end;


changesong(6);
for i = 0, 300 do
	balls[z]	= {x = player['x'], y = player['y'], xs = math.random(-200, 200) / 100, ys = math.random(-200, 200) / 100, life = math.random(15, 120), c = 0};
	z			= z + 1;
end;
totaltime	= timer;
timer		= 0;
dispscore	= 0;
finalscore	= score * (1 + player['graze'] / 100);
while true do

--	centeringhelper();
	timer		= timer + 1;
	doballs();

	if timer >= 60 then
		atimer	= timer - 60;
		tpos	= math.max(120 - atimer, 0);
		atpos	= math.floor(math.pow(tpos / 5, 2));
		text(87, 40 + atpos, "  GAME OVER  ");
	end;

	if timer >= 110 then
		atimer	= timer - 110;
		tpos	= math.max(120 - atimer, 0);
		atpos	= math.floor(math.pow(tpos / 5, 2));

		temp	= totaltime;
		if atimer <= 120 then
			temp	= math.pow(math.min(atimer / 120, 1), 2);
			temp	= totaltime * temp;
		end;
		text(63, 80 + atpos, string.format("Final Time    %4d'%02d\"%02d", math.floor(temp / 3600), math.floor(math.fmod(temp, 3600) / 60), math.fmod(temp, 60)));
	end;

	if timer >= 120 then
		atimer	= timer - 120;
		tpos	= math.max(120 - atimer, 0);
		atpos	= math.floor(math.pow(tpos / 5, 2));
		temp	= score;
		if atimer <= 120 then
			temp	= math.pow(math.min(atimer / 120, 1), 2);
			temp	= score * temp;
		end;
		text(64, 89 + atpos, string.format("Score     %9dpts", temp));
	end;

	if timer >= 180 then
		atimer	= timer - 180;
		tpos	= math.max(120 - atimer, 0);
		atpos	= math.floor(math.pow(tpos / 5, 2));
		temp	= score * (player['graze'] / 100);
		if atimer <= 120 then
			temp	= math.pow(math.min(atimer / 120, 1), 2);
			temp	= (score * (player['graze'] / 100)) * temp;
		elseif atimer >= 250 then
			atimer2	= atimer - 250;
			temp	= temp * math.max(0, 1 - (atimer2 / 100));
		end;
		text(64,  107 + atpos, string.format("Bonus     %9dpts", temp));
	end;
	if timer >= 180 then
		atimer	= timer - 180;
		tpos	= math.max(120 - atimer, 0);
		atpos	= math.floor(math.pow(tpos / 5, 2));
		temp	= score;
		if atimer >= 250 then
			atimer2	= atimer - 250;
			temp	= score * (1 + player['graze'] / 100 * math.min(1, atimer2 / 100));
		end;
		text(62, 116 + atpos, string.format("Final Score %9dpts", temp));
	end;

	if timer >= 60 then
		atimer	= timer - 60;
		tpos	= math.max(120 - atimer, 0);
		atpos	= math.floor(math.pow(tpos / 5, 2));
		text(224 - atpos, 220, version_id);
	end;

	if timer >= 530 and (true or timer <= 830) then
		atimer	= timer - 530;
		rate	= math.floor(math.max(6, (5000000 - finalscore) / 100000));
--		text(8, 8, rate);
		if math.fmod(timer, rate) == 0 then
			tempx	= math.random(0x20, 0xE0);
			tempy	= math.random(0x30, 0x80);

			for i = 0, 100 do
				balls[z]	= {x = tempx, y = tempy, xs = math.random(-100, 100) / 100, ys = math.random(-300, -100) / 100, life = math.random(15, 120), c = -1};
				z			= z + 1;
			end;
		end;
	end;

--	text(  2, 222, string.format("%6dpts", score));

	FCEU.frameadvance();

end;