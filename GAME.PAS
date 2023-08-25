program game;
uses crt,graph,windos,sprite;
var SvInt1C: procedure;
	gd,gm:integer;
    i,j,bonusx,bonusy,napr,napr2,timer,speed:integer;
	fps:longint;
	fpss, scores, mes:string;
    pause, gameover, effects,drawcomplete,bonus,cheat,wallwalk,beep:boolean;
    k:char;
	Driver, Mode, TestDriver, ErrCode: Integer;
	posx,posy : array[1..240] of integer;
	length, nextx, nexty, godmode:integer;

{$F+}
function TestDetect: Integer;
begin
	TestDetect := 1;
end;
{$F-}

procedure NewInt1C; interrupt; {ÝáÖ¤¨¦çá  Öåá ¢ åñë ¨å 18.2 á ó ë ã¨ÆçÔ¦ç}
begin
	timer:=timer+1;
	if beep then begin beep:=false;NoSound;end;
end;

procedure cheaton;
begin
	for i:=0 to 19 do
		for j:=0 to 11 do
			drawbonus(i,j);
	for i:=1 to length do 
		drawsegment(posx[i],posy[i]);
end;

function collision(x,y,startpos:integer):boolean;
var result:boolean;
begin
	result:=false;
	for i:=startpos to length-1 do begin
		if (x=posx[i]) and (y=posy[i]) then result:=true;
	end;
	if (not wallwalk) and ((x>19)or(y>11)or(x<0)or(y<0)) then result:=true;
	collision:=result;
end;

procedure start;
begin
	fillboard;
	napr:=1;napr2:=1;i:=3;j:=3; timer:=0 ;effects:=true; drawcomplete:=false; bonus:=false; pause:=false;
    posx[1]:=7;posx[2]:=6;posx[3]:=5;posx[4]:=4;posx[5]:=3;
    posy[1]:=5;posy[2]:=5;posy[3]:=5;posy[4]:=5;posy[5]:=5;
	nextx:=posx[1];nexty:=posy[1];
    length:=3;mes:='pause';gameover:=false; cheat:=false;speed:=4;wallwalk:=false;godmode:=0;
	for i:=length downto 1 do
		drawsegment(posx[i],posy[i]);
	
	pain;
	while KeyPressed do k:=ReadKey;
end;


begin
	GetIntVec($1C,@SvInt1C);
	SetIntVec($1C,@NewInt1C);
	TestDriver := InstallUserDriver('VGA256', @TestDetect);
	if GraphResult <> grOk then
	begin
		Writeln('Error set mode VGA 320x200x256');
		Halt(1);
	end;
	Driver := Detect;
	InitGraph(Driver, Mode, ' ');
	ErrCode := GraphResult;
	if ErrCode <> grOk then
	begin
		Writeln('VGA driver error: ', ErrCode);
		Halt(1);
	end;

	start;

	Randomize;
	repeat
		if timer>=speed then begin
			timer:=0;
			str(napr,fpss);str(length-3,scores);
			bar(0,192,320,200);
			OutTextXY(5,192,'Score: '+scores);
			OutTextXY(85,192,'fps='+fpss);
			if wallwalk then OutTextXY(310,192,'w');
			if godmode=1 then OutTextXY(305,192,'g');if godmode=2 then OutTextXY(305,192,'G');
			if pause then OutTextXY(165,192,mes);
			fps:=0;
			drawcomplete:=false;
		end;

		fps:=fps+1;

		if (keypressed) then
		begin
			k:=readkey;
			if (k=#77) and (napr<>3)and (napr2=0) then napr2:=1
			else if (k=#80) and (napr<>4)and (napr2=0) then napr2:=2
			else if (k=#75) and (napr<>1)and (napr2=0) then napr2:=3
			else if (k=#72) and (napr<>2)and (napr2=0) then napr2:=4
			else if k='e' then effects:=not effects
			else if k='w' then wallwalk:=not wallwalk
			else if k='g' then godmode:=godmode +1
			else if (k='p')and (gameover) then begin pause:=not pause;start; end
			else if k='p' then pause:=not pause
			else if k='n' then start
			else if (k='s') and (speed>1) then speed:=speed-1
			else if k='c' then begin cheaton; cheat:=true; bonusx:=-1; bonus:=true;end;
		end;
		if godmode>2 then godmode:=0;

		if (not drawcomplete)and (not pause) then begin
			if (napr2>0) then begin
				napr:=napr2;
				napr2:=0;
			end;

			if 	(napr=1) then nextx:=posx[1]+1
			else if (napr=2) then nexty:=posy[1]+1
			else if (napr=3) then nextx:=posx[1]-1
			else if (napr=4) then nexty:=posy[1]-1;
			
			if (not collision(nextx,nexty,4))then begin
				if (not cheat) then begin
					boardsegment(posx[length],posy[length]);
				end;
				
				for i:=length downto 2 do begin
					posx[i]:=posx[i-1];
					posy[i]:=posy[i-1];
				end;
				posx[1]:=nextx;
				posy[1]:=nexty;
				
				if (posx[1]=bonusx) and (posy[1]=bonusy) then begin length:=length+1; bonus:=false; Sound(1568);beep:=true;end;

				if wallwalk then begin
					if (posx[1]>20) then posx[1]:=0
					else if (posy[1]>11) then posy[1]:=0
					else if (posx[1]<0) then posx[1]:=19
					else if (posy[1]<0) then posy[1]:=11;
				end;

				drawsegment(posx[1],posy[1]);
				


				if cheat then length:=length+1;
				if length=240 then begin mes:='you win!'; pause:=true; gameover:=true;end;

				if not bonus then repeat
					bonusx:=random(20);
					bonusy:=random(12);
					if not collision(bonusx,bonusy,1) then
						bonus:=true;
					if bonus then drawbonus(bonusx,bonusy);
				until(bonus);
				
				
			end
			else if (godmode=0) then begin mes:='Game over!'; pause:=true; gameover:=true;end
			else if (godmode=1) then begin nextx:=posx[1]; nexty:=posy[1]; end
			else begin
				
				for i:=1 to length div 2 do
				begin
					j:=posx[i];
					posx[i]:=posx[length-i+1];
					posx[length-i+1]:=j;
					j:=posy[i];
					posy[i]:=posy[length-i+1];
					posy[length-i+1]:=j;
				end;
				nextx:=posx[1];
				nexty:=posy[1];
				if (posx[1]>posx[2]) then napr:=1;
				if (posx[2]>posx[1]) then napr:=3;
				if (posy[1]>posy[2]) then napr:=2;
				if (posy[2]>posy[1]) then napr:=4;
			end;
	
	
			drawcomplete:=true;
		end;
	until k=#27;
	SetIntVec($1C,@SvInt1C);
	closegraph
end.
