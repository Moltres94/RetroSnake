program game;
uses crt,graph,windos,sprite;
var SvInt1C: procedure;
	gd,gm:integer;
    i,j,bonusx,bonusy,napr,napr2,timer:integer;
	fps:longint;
	fpss, scores, mes:string;
    pause, gameover, effects,drawcomplete,bonus,cheat:boolean;
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
	for i:=1 to length do 
		drawsegment(posx[i],posy[i]);
	napr:=1;i:=3;j:=3; timer:=0 ;effects:=true; drawcomplete:=false; bonus:=false;
    posx[1]:=7;posx[2]:=6;posx[3]:=5;posx[4]:=4;posx[5]:=3;
    posy[1]:=5;posy[2]:=5;posy[3]:=5;posy[4]:=5;posy[5]:=5;
    length:=3;mes:='pause';
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

	fillboard;
	napr:=1;i:=3;j:=3; timer:=0 ;effects:=true; drawcomplete:=false; bonus:=false;
        posx[1]:=7;posx[2]:=6;posx[3]:=5;posx[4]:=4;posx[5]:=3;
        posy[1]:=5;posy[2]:=5;posy[3]:=5;posy[4]:=5;posy[5]:=5;
        length:=3; mes:='pause';
	for i:=1 to length do 
		drawsegment(posx[i],posy[i]);
	Randomize;
	repeat
		if timer>=4 then begin
			timer:=0;
			str(fps,fpss);str(length-3,scores);
			bar(0,192,320,200);
			OutTextXY(5,192,'Score: '+scores);
			OutTextXY(85,192,'fps='+fpss);
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
			else if (k='p')and (gameover) then begin pause:=not pause;start; end
			else if (k='p') then pause:=not pause
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
			if not cheat then
				boardsegment(posx[length],posy[length]);
			
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
			if not bonus then begin
				bonusx:=random(20);
				bonusy:=random(12);
				drawbonus(bonusx,bonusy);
				bonus:=true;
			end;

			drawcomplete:=true;
		end;
	until k=#27;
	SetIntVec($1C,@SvInt1C);
	closegraph
end.
