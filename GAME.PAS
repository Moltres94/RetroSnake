program game;
uses crt,graph,windos,sprite;
var SvInt1C: procedure;
	gd,gm:integer;
    i,j,ib,jb,napr,napr2,timer:integer;
	fps:longint;
	fpss:string;
    error:integer;
    effects,drawcomplete:boolean;
    k:char;
	Driver, Mode, TestDriver, ErrCode: Integer;
	

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
	napr:=1;i:=3;j:=3; timer:=0 ;effects:=true; drawcomplete:=false;
	repeat
		if timer>=4 then begin 
			timer:=0; 
			str(fps,fpss);
			bar(0,192,320,200);
			OutTextXY(5,192,'fps='+fpss);
			fps:=0; 
			drawcomplete:=false;
		end;
		
		fps:=fps+1;

		if (keypressed) and (napr2=0) then
		begin
			k:=readkey;
			if k=#77 then napr2:=1
			else if k=#80 then napr2:=2
			else if k=#75 then napr2:=3
			else if k=#72 then napr2:=4
			else if k='e' then effects:=not effects;
		end;

		

		
		if not drawcomplete then begin
			if (napr2>0) then begin
				napr:=napr2;
				napr2:=0;
			end;
			if napr=1 then i:=i+1
			else if napr=2 then j:=j+1
			else if napr=3 then i:=i-1
			else if napr=4 then j:=j-1;
			drawsegment(i,j);
			
			if (i<0) or (i>19) or (j<0) or (j>11) then begin
				fillboard;
				napr:=random(4)+1;
				i:=random(20);
				j:=random(12);
			end
			else if timer=random(18) then begin
				ib:=random(20);
				jb:=random(12);
				drawbonus(ib,jb);
			end;
			drawcomplete:=true;
		end;
	until k=#27;
	SetIntVec($1C,@SvInt1C);
	closegraph
end.
