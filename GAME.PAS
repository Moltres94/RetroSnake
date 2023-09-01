program game;
uses crt,graph,windos,sprite;
var SvInt1C: procedure;
	gd,gm:integer;
    i,j,bonusx,bonusy,napr,napr2,timer,speed,color:integer;
	fpss, scores, mes:string;
    pause, gameover, effects,drawcomplete,bonus,cheat,wallwalk:boolean;
	needdraw,needclear,music, nextcolor:boolean;
    k:char;
	Driver, Mode, TestDriver, ErrCode: Integer;
	posx,posy : array[1..240] of integer;
	length, best,nextx, nexty, godmode,beep:integer;
	
{$F+}
function TestDetect: Integer;
begin
	TestDetect := 1;
end;
{$F-}

procedure NewInt1C; interrupt; {ÝáÖ¤¨¦çá  Öåá ¢ åñë ¨å 18.2 á ó ë ã¨ÆçÔ¦ç}
begin
	timer:=timer+1;
	if beep>0 then begin beep:=beep-1;if beep=0 then NoSound;end;
end;

function crypt(a:integer;mode:boolean):integer;
const
secret:array[1..5] of byte = (9,3,6,7,1);
var b,c,len,r:integer; f:text;
begin
	if (mode) then begin if a>281 then a:=281; a:=a*71; end
	else begin {if not mode}
		assign(f,'score.ini');
		reset(f);
		read(f,a);
		close(f);
	end;
	
	len:=1;	b:=1;	r:=0;
	if a>9999 then len:=5
	else if a>999 then len:=4
	else if a>99 then len:=3
	else if a>9 then len:=2;
	
	for i:=1 to len do
	begin
		 if (mode) then begin
			c:=(a div b mod 10)+secret[i];
			if c>9 then c:=c-10;
		end
		else begin 
			c:=(a div b mod 10)-secret[i];
			if c<0 then c:=c+10;
		end;	 
		r:=r+(c*b);
		b:=b*10;
	end;

	if (mode) then begin
		assign(f,'score.ini');
		rewrite(f);
		writeln(f,r);
		close(f);
	end
	else begin {not mode}
		if a =0 then begin crypt:=0; exit; end;
		if (r mod 71) <>0 then begin crypt:=-2; exit; end;
		r:=r div 71;		
	end;
	crypt:=r;
end;

procedure cheaton;
begin
	for i:=0 to 19 do
		for j:=0 to 11 do
			drawbonus(i,j);
	drawhead(posx[1],posy[1]);
	for i:=2 to length do 
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

procedure drawstatus;
begin
			str(best,fpss);str(length-3,scores);
			setfillstyle(1,141+color);bar(0,192,320,200);
			setcolor(15);
			OutTextXY(5,192,'Score: '+scores);
			OutTextXY(85,192,'Best:'+fpss);
			if music then OutTextXY(298,192,'m');
			if wallwalk then OutTextXY(312,192,'w');
			if godmode=1 then OutTextXY(305,192,'g');if godmode=2 then OutTextXY(305,192,'G');
			if pause then OutTextXY(165,192,mes);
			needdraw:=false;
end;

procedure start;
begin
	NoSound;
	if nextcolor then color:=random(24);
	colorshift(color);
	fillboard;
	setfillstyle(1,141+color);bar(0,192,320,200);setcolor(15);OutTextXY(30,192,'Get ready!');needdraw:=true;
	napr:=1;napr2:=1;i:=3;j:=3; effects:=true; drawcomplete:=false; bonus:=false; pause:=false; 
    posx[1]:=7;posx[2]:=6;posx[3]:=5;
    posy[1]:=5;posy[2]:=5;posy[3]:=5;
	nextx:=posx[1];nexty:=posy[1];needclear:=true;
    length:=3;mes:='pause';gameover:=false; cheat:=false;speed:=4;godmode:=0;
	for i:=length downto 2 do
		drawsegment(posx[i],posy[i]);
	drawhead(posx[1],posy[1]);
	if music then pain;
	setfillstyle(1,141+color);bar(0,192,320,200);setcolor(14);OutTextXY(30,192,'Go!');
	needdraw:=true; timer:=0 ;repeat until(timer=4);
	while KeyPressed do k:=ReadKey;
end;

procedure gameoverp;
begin
	if (length-3)>best then begin 
		best:=length-3;
		crypt(best,true);
		if best>=20 then nextcolor:=true;
	end;
	pause:=true; gameover:=true;needdraw:=true;Sound(100);beep:=9;
end;

procedure bang;
begin
	fillboard;
	for i:=1 to length do begin
		posx[i]:=random(20);
		posy[i]:=random(12);
		if i=1 then drawhead(posx[i],posy[i])
			else drawsegment(posx[i],posy[i]);
	end;
	mes:='Bang!'; pause:=true; gameoverp;needdraw:=true;
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

	best:=crypt(0,false);
	music:=true;
	start;

	Randomize;
	repeat
		if timer>=speed then begin
			timer:=0;
			if (needdraw) then drawstatus;
			drawcomplete:=false;
		end;

		if (keypressed) then
		begin
			k:=readkey;
			if (k=#77) and (napr<>3)and (napr2=0) then napr2:=1
			else if (k=#80) and (napr<>4)and (napr2=0) then napr2:=2
			else if (k=#75) and (napr<>1)and (napr2=0) then napr2:=3
			else if (k=#72) and (napr<>2)and (napr2=0) then napr2:=4
			else if k='e' then effects:=not effects
			else if k='w' then  begin wallwalk:=not wallwalk; needdraw:=true; end
			else if k='g' then  begin godmode:=godmode +1; needdraw:=true; end
			else if k='m' then  begin music:=not music; needdraw:=true; end
			else if ((k='p') or (k=#13)) and (gameover) then begin pause:=not pause;start; end
			else if (k='p') or (k=#13) then begin pause:=not pause;needdraw:=true; end
			else if k='b' then bang
			else if k='n' then start
			{else if k='x' then 	color:=random(24)}
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
				if (not cheat)and (needclear) then begin
					boardsegment(posx[length],posy[length]);
				end;	
				
				needclear:=true;
				
				for i:=length downto 2 do begin
					posx[i]:=posx[i-1];
					posy[i]:=posy[i-1];
				end;
				posx[1]:=nextx;
				posy[1]:=nexty;
				
				if (posx[1]=bonusx) and (posy[1]=bonusy) then 
					begin length:=length+1; needdraw:=true; needclear:=false; bonus:=false; Sound(1568);beep:=1;end;

				if wallwalk then begin
					if (posx[1]>20) then posx[1]:=0
					else if (posy[1]>11) then posy[1]:=0
					else if (posx[1]<0) then posx[1]:=19
					else if (posy[1]<0) then posy[1]:=11;
				end;

				drawhead(posx[1],posy[1]);
				drawsegment(posx[2],posy[2]);
				
				if cheat then begin length:=length+1; needdraw:=true;Sound(1568);beep:=1;end;
				if length>=240 then begin mes:='you win!'; gameoverp; end;

				if not bonus then repeat
					bonusx:=random(20);
					bonusy:=random(12);
					if not collision(bonusx,bonusy,1) then
						bonus:=true;
					if bonus then drawbonus(bonusx,bonusy);
				until(bonus);
							
			end
			else if (godmode=0) then begin mes:='Game over!';gameoverp; end
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
	NoSound;
	SetIntVec($1C,@SvInt1C);
	closegraph
end.
