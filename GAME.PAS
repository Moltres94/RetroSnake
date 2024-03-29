program game;
uses crt,graph,windos,sprite;
var SvInt1C: procedure;
	gd,gm, bonus2type,bonustimer:integer;
    i,j,bonusx,bonusy,bonusx2,bonusy2,napr,napr2,timer,speed,color:integer;
	fpss, scores, mes, cheats:string;
    pause, gameover, effects,drawcomplete,bonus,cheat,wallwalk:boolean;
	needdraw,needclear,music, nextcolor,needbonus,exi:boolean;
	thin,debug,newskin,cheatsmode:boolean;
    k:char;
	Driver, Mode, TestDriver, ErrCode: Integer;
	posx,posy : array[1..240] of integer;
	segm:array[1..240] of byte;
	nextsegment:byte;
	lengt, best,nextx, nexty, godmode,beep,mestimer:integer;
	
{$F+}
function TestDetect: Integer;
begin
	TestDetect := 1;
end;
{$F-}

procedure NewInt1C; interrupt; {��֤���� ��ᠢ���련� 18.2 �� � ���Ԧ�}
begin
	timer:=timer+1;
	if beep>=0 then begin beep:=beep-1;if beep=0 then NoSound;end;
	if mestimer>=0 then begin mestimer:=mestimer-1;if mestimer=0 then needdraw:=true;end;
	if bonustimer>=0 then begin if not pause then bonustimer:=bonustimer-1;end;if bonustimer=0 then begin 
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
	drawhead(posx[1],posy[1],godmode,segm[1]);
	for i:=2 to lengt do 
		if (i=lengt) and (newskin) then drawhead(posx[i],posy[i],0,segm[i])
			else drawsegment(posx[i],posy[i],segm[i]);
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
			str(best,fpss);str(lengt-3,scores);
			if (cheatsmode) then setfillstyle(1,15)
				else setfillstyle(1,141+color);
			bar(0,192,320,200);
			if (cheatsmode) then setcolor(141+color)
				else setcolor(15);
			OutTextXY(5,192,'Score: '+scores);
			if length(cheats)>0 then OutTextXY(85,192,'Best:'+cheats)
				else OutTextXY(85,192,'Best:'+fpss);
			{if bonustimer>0 then begin
				str(bonustimer,bonuss);
				OutTextXY(165,192,bonuss);
			end;}
			if music then OutTextXY(298,192,'m');
			if wallwalk then OutTextXY(312,192,'w');
			if pause then OutTextXY(165,192,mes);
			if mestimer>0 then OutTextXY(165,192,mes);
			
			if (pause)and(debug) then begin bar(164,8,220,9*lengt+8);
			for i:=1 to lengt do begin
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
	
	if newskin then begin
		segm[1]:=1;segm[2]:=1;segm[3]:=5;
	end else
	if thin then begin
		segm[1]:=1;segm[2]:=1;segm[3]:=1;
	end;
	nextx:=posx[1];nexty:=posy[1];needclear:=true;needbonus:=false;
    lengt:=3;mes:='pause';gameover:=false; cheat:=false;speed:=4;godmode:=0;mestimer:=0;
	for i:=lengt downto 2 do begin
		if (newskin) and (i=lengt) then drawhead(posx[i],posy[i],0,segm[i])
			else drawsegment(posx[i],posy[i],segm[i]);
	end;
	drawhead(posx[1],posy[1],0,segm[1]);
	if music then pain;
	setfillstyle(1,141+color);bar(0,192,320,200);setcolor(14);OutTextXY(30,192,'Go!');
	needdraw:=true; timer:=0 ;repeat until(timer=4);
	while KeyPressed do k:=ReadKey;
end;

procedure gameoverp;
begin
	if (lengt-3)>best then begin 
		best:=lengt-3;
		crypt(best,true);
		if best>=20 then nextcolor:=true;
	end;
	pause:=true; gameover:=true;needdraw:=true;Sound(100);beep:=9;
end;

procedure bang;
begin
	fillboard;
	for i:=1 to lengt do begin
		posx[i]:=random(20);
		posy[i]:=random(12);
		if i=1 then drawhead(posx[i],posy[i],godmode,segm[i])
			else if (i=lengt) and (newskin) then drawhead(posx[i],posy[i],1,segm[i])
				else drawsegment(posx[i],posy[i],segm[i]);
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
	music:=true;debug:=false;{setthin(false);}setdebug(false);setnewskin(false);cheats:='';
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
			if (k='s') and (cheats='') then begin cheats:='s';needdraw:=true;end 
				else if (k='n') and (cheats='s') then begin cheats:='sn';needdraw:=true;end 
				else if (k='a') and (cheats='sn') then begin cheats:='sna' ;needdraw:=true;end 
				else if (k='k') and (cheats='sna') then begin cheats:='snak' ;needdraw:=true;end 
				else if (k='e') and (cheats='snak') then begin cheatsmode:=true;needdraw:=true;cheats:=''end 
				else if length(cheats)>0 then begin cheats:='';needdraw:=true;end; 
			if (k=#77) and (napr<>3)and (napr2=0) then napr2:=1
			else if (k=#80) and (napr<>4)and (napr2=0) then napr2:=2
			else if (k=#75) and (napr<>1)and (napr2=0) then napr2:=3
			else if (k=#72) and (napr<>2)and (napr2=0) then napr2:=4
			else if ((k=#27)or (k='y')) and (pause) then begin mes:='Bye!';gameoverp; needdraw:=true;exi:=true; end
			else if (k=#27)  then begin mes:='Exit to DOS?'; pause:=true; needdraw:=true; end
			else if k='e' then effects:=not effects
			else if k='d' then begin debug:=not debug; setdebug(debug); end
			else if k='t' then begin thin:=not thin;  {setthin(thin);}end
			else if (k='w')and (cheatsmode) then  begin wallwalk:=not wallwalk; needdraw:=true; end
			else if (k='g')and (not pause)and (cheatsmode) then  begin 
					godmode:=godmode +1; if godmode>3 then godmode:=0; mestimer:=4; str(godmode,mes);mes:='godmode: '+mes; needdraw:=true; 
				end
			else if k='m' then  begin music:=not music; needdraw:=true; end
			else if ((k='p') or (k=#13)) and (gameover) then begin pause:=not pause;start; end
			else if (k='p') or (k=#13) then begin mes:='pause';pause:=not pause;needdraw:=true; end
			else if k='b' then bang
			else if (k='n')and (length(cheats)=0) then start
			else if k='l' then light
			else if (k='1')and (cheatsmode) then begin boardsegment(bonusx2,bonusy2);needdraw:=true;bonus2type:=0;needbonus:=true; end
			else if k='x' then 	nextcolor:=true
			else if (k='s') then begin newskin:=not newskin; if not newskin then segm[1]:=0; setnewskin(newskin);end
			else if (k='+') and (speed>1) then speed:=speed-1
			else if (k='c')and (cheatsmode) then begin cheaton; cheat:=true; bonusx:=-2; bonus:=true;end;
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
			
			if (not collision(nextx,nexty,4,lengt-1)) or (godmode=3)then begin
				if godmode =3 then if collision(posx[lengt],posy[lengt],1,lengt-1) then needclear:=false;
				if (not cheat)and (needclear) then begin
					boardsegment(posx[lengt],posy[lengt]);
					if (newskin) then {���� �����}
					begin
						if (posy[lengt-2]=posy[lengt-1])and (posx[lengt-2]>posx[lengt-1])then segm[lengt-1]:=5 {�����}
						else if (posy[lengt-2]=posy[lengt-1])and (posx[lengt-2]<posx[lengt-1])then segm[lengt-1]:=7 {�Ш��}
						else if (posy[lengt-2]<posy[lengt-1])then segm[lengt-1]:=8 {���}
						else if (posy[lengt-2]>posy[lengt-1])then segm[lengt-1]:=6; {�Է�}
						drawhead(posx[lengt-1],posy[lengt-1],0,segm[lengt-1]); 
					end;
				end;	

					
				needclear:=true;
				
				
				for i:=lengt downto 2 do begin
					posx[i]:=posx[i-1];
					posy[i]:=posy[i-1];
					segm[i]:=segm[i-1];
				end;
				posx[1]:=nextx;
				posy[1]:=nexty;
				segm[2]:=0;
				if (thin)or(newskin) then begin
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
					inc(lengt); needdraw:=true; needclear:=false; bonus:=false; Sound(1568);beep:=1;
				end;
				if (posx[1]=bonusx2) and (posy[1]=bonusy2) then 
				begin 
					godmode:=bonus2type;
					inc(lengt); needdraw:=true; needclear:=false; bonus2type:=0; bonusy2:=-2; bonustimer:=100;Sound(1568);beep:=1;
				end;

				if (wallwalk) or (godmode=3) then begin
					if (posx[1]>20) then posx[1]:=0
					else if (posy[1]>11) then posy[1]:=0
					else if (posx[1]<0) then posx[1]:=19
					else if (posy[1]<0) then posy[1]:=11;
				end;

				drawhead(posx[1],posy[1],godmode,segm[1]);
				drawsegment(posx[2],posy[2],segm[2]);
				
				if cheat then begin lengt:=lengt+1; needdraw:=true;Sound(1568);beep:=1;end;
				if lengt>=240 then begin mes:='you win!'; gameoverp; end;

				if not bonus then repeat
					i:=random(20);
					if (i=1)and (bonustimer=-1) then needbonus:=true;
					bonusx:=random(20);
					bonusy:=random(12);
					if not collision(bonusx,bonusy,1, lengt) then
						bonus:=true;
					if (bonusx=bonusx2) and (bonusy=bonusy2) then bonus:=false;
					if bonus then drawbonus(bonusx,bonusy,0);
				until(bonus);
				if needbonus then repeat
					bonusx2:=random(20);
					bonusy2:=random(12);
					if not collision(bonusx2,bonusy2,1, lengt) then
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
				for i:=1 to lengt div 2 do
				begin
					j:=posx[i];
					posx[i]:=posx[lengt-i+1];
					posx[lengt-i+1]:=j;
					j:=posy[i];
					posy[i]:=posy[lengt-i+1];
					posy[lengt-i+1]:=j;
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
