program game;
uses crt,graph,windos,sprite;
var SvInt1C: procedure;
	gd,gm:integer;
    i,j,bonusx,bonusy,napr,napr2,timer,speed:integer;
	fps:longint;
	fpss, scores, mes:string;
    pause, gameover, effects,drawcomplete,bonus,cheat,wallwalk:boolean;
    k:char;
	Driver, Mode, TestDriver, ErrCode: Integer;
	posx,posy : array[1..240] of integer;
	length:integer;

{$F+}
function TestDetect: Integer;
begin
	TestDetect := 1;
end;
{$F-}

procedure NewInt1C; interrupt; {ÝáÖ¤¨¦çá  Öåá ¢ åñë ¨å 18.2 á ó ë ã¨ÆçÔ¦ç}
begin
	timer:=timer+1;
end;

procedure cheaton;
begin
	for i:=0 to 19 do
		for j:=0 to 11 do
			drawbonus(i,j);
	for i:=1 to length do 
		drawsegment(posx[i],posy[i]);
end;

procedure start;
begin
	fillboard;
	napr:=1;i:=3;j:=3; timer:=0 ;effects:=true; drawcomplete:=false; bonus:=false;
    posx[1]:=7;posx[2]:=6;posx[3]:=5;posx[4]:=4;posx[5]:=3;
    posy[1]:=5;posy[2]:=5;posy[3]:=5;posy[4]:=5;posy[5]:=5;
    length:=3;mes:='pause';gameover:=false; cheat:=false;speed:=4;wallwalk:=false;
	for i:=1 to length do 
		drawsegment(posx[i],posy[i]);
end;

function collision(var x,y:integer; startpos:integer):boolean;
var result:boolean;
begin
	result:=false;
	for i:=startpos to length do begin
		if (x=posx[i]) and (y=posy[i]) then result:=true;
	end;
	collision:=result;
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
			str(fps,fpss);str(length-3,scores);
			bar(0,192,320,200);
			OutTextXY(5,192,'Score: '+scores);
			OutTextXY(85,192,'fps='+fpss);
			if wallwalk then OutTextXY(310,192,'w');
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
			else if (k='p')and (gameover) then begin pause:=not pause;start; end
			else if k='p' then pause:=not pause
			else if k='n' then start
			else if (k='s') and (speed>1) then speed:=speed-1
			else if k='c' then begin cheaton; cheat:=true; bonusx:=-1; bonus:=true;end;
		end;

		if (not drawcomplete)and (not pause) then begin
			if (napr2>0) then begin
				napr:=napr2;
				napr2:=0;
			end;
			
			if (posx[1]=bonusx) and (posy[1]=bonusy) then begin length:=length+1; bonus:=false; end;
			
			
			
			if cheat then length:=length+1;
			if length=240 then begin mes:='you win!'; pause:=true; gameover:=true;end;
			
			if (not cheat) then begin
				boardsegment(posx[length],posy[length]);
				posx[length+1]:=posx[length];posy[length+1]:=posy[length];
			end;
				
			for i:=length downto 2 do begin
				posx[i]:=posx[i-1];
				posy[i]:=posy[i-1];
			end;
			if napr=1 then begin
				posx[1]:=posx[1]+1;
				posy[1]:=posy[1];
			end
			else if napr=2 then begin
				posx[1]:=posx[1];
				posy[1]:=posy[1]+1;
			end
			else if napr=3 then begin
				posx[1]:=posx[1]-1;
				posy[1]:=posy[1];
			end
			else if napr=4 then begin
				posx[1]:=posx[1];
				posy[1]:=posy[1]-1;
			end;
			if wallwalk then begin
				if (posx[1]>19) then posx[1]:=0
				else if (posy[1]>11) then posy[1]:=0
				else if (posx[1]<0) then posx[1]:=19
				else if (posy[1]<0) then posy[1]:=11;
			end
			else if (posx[1]>19)or(posy[1]>11)or(posx[1]<0)or(posy[1]<0) then begin mes:='Game over!'; pause:=true; gameover:=true;end;
			
			if collision(posx[1],posy[1],2) then begin mes:='Game over!'; pause:=true; gameover:=true;end;
			
			if (gameover) then
				drawsegment(posx[length+1],posy[length+1]);


			{fillboard;
			for i:=1 to length do begin}

			drawsegment(posx[1],posy[1]);
			{end;}
			{if (i<0) or (i>19) or (j<0) or (j>11) then begin
				fillboard;
				napr:=random(4)+1;
				i:=random(20);
				j:=random(12);
			end}
			if not bonus then repeat
				bonusx:=random(20);
				bonusy:=random(12);
				if not collision(bonusx,bonusy,1) then
					bonus:=true;
				if bonus then drawbonus(bonusx,bonusy);
			until(bonus);
			
			drawcomplete:=true;
		end;
	until k=#27;
	SetIntVec($1C,@SvInt1C);
	closegraph
end.
