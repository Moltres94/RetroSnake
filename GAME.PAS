program game;
uses crt,graph,windos,sprite;
var SvInt1C: procedure;
	gd,gm, bonus2type,bonustimer:integer;
    i,j,bonusx,bonusy,bonusx2,bonusy2,napr,napr2,timer,speed,color:integer;
	fpss, scores, mes, bonuss:string;
    pause, gameover, effects,drawcomplete,bonus,cheat,wallwalk:boolean;
	needdraw,needclear,music, nextcolor,needbonus,exi:boolean;
	thin,debug:boolean;
    k:char;
	Driver, Mode, TestDriver, ErrCode: Integer;
	posx,posy : array[1..240] of integer;
	segm:array[1..240] of byte;
	nextsegment:byte;
	length, best,nextx, nexty, godmode,beep,mestimer:integer;
	
{$F+}
function TestDetect: Integer;
begin
	TestDetect := 1;
end;
{$F-}

procedure NewInt1C; interrupt; {ÝáÖ¤¨¦çá  Öåá ¢ åñë ¨å 18.2 á ó ë ã¨ÆçÔ¦ç}
begin
	timer:=timer+1;
	if beep>=0 then begin beep:=beep-1;if beep=0 then NoSound;end;
	if mestimer>=0 then begin mestimer:=mestimer-1;if mestimer=0 then needdraw:=true;end;
	if bonustimer>=0 then begin bonustimer:=bonustimer-1;end;if bonustimer=0 then begin 
		boardsegment(bonusx2,bonusy2);needdraw:=true;godmode:=0;bonusx2:=-2;bonus2type:=0;
	end;
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
			drawbonus(i,j,0);
	drawhead(posx[1],posy[1],2,segm[1],debug);
	for i:=2 to length do 
		drawsegment(posx[i],posy[i],segm[i],debug);
end;

function collision(x,y,startpos,endpos:integer):boolean;
var result:boolean;
begin
	result:=false;
	for i:=startpos to endpos do begin
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
			{if bonustimer>0 then begin
				str(bonustimer,bonuss);
				OutTextXY(165,192,bonuss);
			end;}
			if music then OutTextXY(298,192,'m');
			if wallwalk then OutTextXY(312,192,'w');
			if pause then OutTextXY(165,192,mes);
			if mestimer>0 then OutTextXY(165,192,mes);
			
			if (pause)and(debug) then begin bar(164,8,220,9*length+8);
			for i:=1 to length do begin
				mes:='';
				str(posx[i],fpss);
				mes:=mes+fpss+' ';
				str(posy[i],fpss);
				mes:=mes+fpss+' ';
				str(segm[i],fpss);
				mes:=mes+fpss;
				OutTextXY(165,i*9,mes);
			end;end;
			needdraw:=false;
end;

procedure start;
begin
	NoSound;
	if nextcolor then begin color:=random(24);nextcolor:=false;end;
	colorshift(color);
	fillboard;
	setfillstyle(1,141+color);bar(0,192,320,200);setcolor(15);OutTextXY(30,192,'Get ready!');needdraw:=true;
	napr:=1;napr2:=1;i:=3;j:=3; effects:=true; drawcomplete:=false; bonus:=false; bonus2type:=0;bonusy2:=-2;pause:=false; 
    posx[1]:=7;posx[2]:=6;posx[3]:=5;
    posy[1]:=5;posy[2]:=5;posy[3]:=5;
	if thin then begin
		segm[1]:=1;segm[2]:=1;segm[3]:=5;
	end;
	nextx:=posx[1];nexty:=posy[1];needclear:=true;needbonus:=false;
    length:=3;mes:='pause';gameover:=false; cheat:=false;speed:=4;godmode:=0;mestimer:=0;
	for i:=length downto 2 do
		drawsegment(posx[i],posy[i],segm[i],debug);
	drawhead(posx[1],posy[1],0,segm[1],debug);
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
		if i=1 then drawhead(posx[i],posy[i],5,segm[1],debug)
			else drawsegment(posx[i],posy[i],segm[i],debug);
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
	music:=true;debug:=false;
	start;

	Randomize;
	repeat
		if timer>=speed then begin
			timer:=0;	
			drawcomplete:=false;
		end;
		
		if (needdraw) then drawstatus;
		
		if (keypressed) then
		begin
			k:=readkey;
			if (k=#77) and (napr<>3)and (napr2=0) then napr2:=1
			else if (k=#80) and (napr<>4)and (napr2=0) then napr2:=2
			else if (k=#75) and (napr<>1)and (napr2=0) then napr2:=3
			else if (k=#72) and (napr<>2)and (napr2=0) then napr2:=4
			else if ((k=#27)or (k='y')) and (pause) then begin mes:='Bye!';gameoverp; needdraw:=true;exi:=true; end
			else if (k=#27)  then begin mes:='Exit to DOS?'; pause:=true; needdraw:=true; end
			else if k='e' then effects:=not effects
			else if k='d' then debug:=not debug
			else if k='t' then begin thin:=not thin; if not thin then segm[1]:=0; end
			else if k='w' then  begin wallwalk:=not wallwalk; needdraw:=true; end
			else if (k='g')and (not pause) then  begin 
					godmode:=godmode +1; if godmode>3 then godmode:=0; mestimer:=4; str(godmode,mes);mes:='godmode: '+mes; needdraw:=true; 
				end
			else if k='m' then  begin music:=not music; needdraw:=true; end
			else if ((k='p') or (k=#13)) and (gameover) then begin pause:=not pause;start; end
			else if (k='p') or (k=#13) then begin mes:='pause';pause:=not pause;needdraw:=true; end
			else if k='b' then bang
			else if k='n' then start
			{else if k='x' then 	color:=random(24)}
			else if (k='s') and (speed>1) then speed:=speed-1
			else if k='c' then begin cheaton; cheat:=true; bonusx:=-2; bonus:=true;end;
		end;
		

		if (not drawcomplete)and (not pause) then begin
			if (napr2>0) then begin
				napr:=napr2;
				napr2:=0;
			end;
			
			{if (napr=1) or (napr=3) then nextsegment:=1
				else nextsegment:=2;}
			if 	(napr=1) then nextx:=posx[1]+1
			else if (napr=2) then nexty:=posy[1]+1
			else if (napr=3) then nextx:=posx[1]-1
			else if (napr=4) then nexty:=posy[1]-1;
			
			if (not collision(nextx,nexty,4,length-1)) or (godmode=3)then begin
				if godmode =3 then if collision(posx[length],posy[length],1,length-1) then needclear:=false;
				if (not cheat)and (needclear) then begin
					boardsegment(posx[length],posy[length]);
					if (debug) and (thin) then
					begin
						if (posy[length-2]=posy[length-1])and (posx[length-2]>posx[length-1])then segm[length-1]:=5 {ëØá ëÖ}
						else if (posy[length-2]=posy[length-1])and (posx[length-2]<posx[length-1])then segm[length-1]:=7 {ëÐ¨ëÖ}
						else if (posy[length-2]<posy[length-1])then segm[length-1]:=8 {ëë¨áµ}
						else if (posy[length-2]>posy[length-1])then segm[length-1]:=6; {ëÔ·ó}
						drawhead(posx[length-1],posy[length-1],0,segm[length-1],true); {á·ãç¨Ò µëÖãå}
					end;
				end;	

					
				needclear:=true;
				
				
				for i:=length downto 2 do begin
					posx[i]:=posx[i-1];
					posy[i]:=posy[i-1];
					segm[i]:=segm[i-1];
				end;
				posx[1]:=nextx;
				posy[1]:=nexty;
				segm[2]:=0;
				if thin then begin
					segm[1]:=napr;
					
					if posx[1]=posx[3] then segm[2]:=2
					else if posy[1]=posy[3] then segm[2]:=1
					else if (posx[3]-posx[1]=1)  and (posy[3]-posy[1]=-1) and (posx[2]=posx[1]) then segm[2]:=5
					else if (posx[3]-posx[1]=-1) and (posy[3]-posy[1]=1)  and (posx[2]=posx[3]) then segm[2]:=5
					
					else if (posx[3]-posx[1]=1)  and (posy[3]-posy[1]= 1) and (posx[2]=posx[3]) then segm[2]:=6
					else if (posx[3]-posx[1]=-1) and (posy[3]-posy[1]=-1) and (posx[2]=posx[1]) then segm[2]:=6
					
					else if (posx[3]-posx[1]=1)  and (posy[3]-posy[1]=-1) {and (posx[2]=posx[3])} then segm[2]:=3
					else if (posx[3]-posx[1]=-1) and (posy[3]-posy[1]=1)  {and (posx[2]=posx[1])} then segm[2]:=3
					
					else if (posx[3]-posx[1]=1)  {and (posy[3]-posy[1]= 1) =and (posx[2]=posx[1])} then segm[2]:=4
					else if (posx[3]-posx[1]=-1) {and (posy[3]-posy[1]=-1) and (posx[2]=posx[3])} then segm[2]:=4;
				end;
				
				if (posx[1]=bonusx) and (posy[1]=bonusy) then 
				begin 
					inc(length); needdraw:=true; needclear:=false; bonus:=false; Sound(1568);beep:=1;
				end;
				if (posx[1]=bonusx2) and (posy[1]=bonusy2) then 
				begin 
					godmode:=bonus2type;
					inc(length); needdraw:=true; needclear:=false; bonus2type:=0; bonusy2:=-2; bonustimer:=100;Sound(1568);beep:=1;
				end;

				if (wallwalk) or (godmode=3) then begin
					if (posx[1]>20) then posx[1]:=0
					else if (posy[1]>11) then posy[1]:=0
					else if (posx[1]<0) then posx[1]:=19
					else if (posy[1]<0) then posy[1]:=11;
				end;

				drawhead(posx[1],posy[1],godmode,segm[1],debug);
				drawsegment(posx[2],posy[2],segm[2],debug);
				
				if cheat then begin length:=length+1; needdraw:=true;Sound(1568);beep:=1;end;
				if length>=240 then begin mes:='you win!'; gameoverp; end;

				if not bonus then repeat
					i:=random(20);
					if (i=1)and (bonustimer=-1) then needbonus:=true;
					bonusx:=random(20);
					bonusy:=random(12);
					if not collision(bonusx,bonusy,1, length) then
						bonus:=true;
					if (bonusx=bonusx2) and (bonusy=bonusy2) then bonus:=false;
					if bonus then drawbonus(bonusx,bonusy,0);
				until(bonus);
				if needbonus then repeat
					bonusx2:=random(20);
					bonusy2:=random(12);
					if not collision(bonusx2,bonusy2,1, length) then
						bonus2type:=random(3)+1;
					if (bonusx=bonusx2) and (bonusy=bonusy2) then bonus2type:=0;
					if (bonus2type>0) then drawbonus(bonusx2,bonusy2,bonus2type);
					needbonus:=false;
					bonustimer:=100;
				until(bonus2type>0);
							
			end
			else if (godmode=0) then begin mes:='Game over!';gameoverp; end
			else if (godmode=1) then begin nextx:=posx[1]; nexty:=posy[1]; end
			else if (godmode=2) then begin		
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
	until exi;
	NoSound;
	SetIntVec($1C,@SvInt1C);
	closegraph
end.
