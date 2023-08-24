program game;
uses crt,graph,windos;
var SvInt1C: procedure;
	gd,gm:integer;
    i,j,ib,jb,napr,napr2,timer,fps:integer;
	fpss:string;
    error:integer;
    effects:boolean;
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

procedure fillboard;
var wi,wj:integer;
begin
        setfillstyle(1,216);
        bar(0,0,320,200);
        setfillstyle(1,214);
        wi:=0;
        wj:=0;
        repeat
                bar(wi,wj,wi+15,wj+15);
                wi:=wi+32;
                if wi>=320 then
                begin
                        if wi=320 then wi:=16
                        else wi:=0;
                        wj:=wj+16;
                        end;
                until wj>=192;
end;

procedure drawbonus(x,y:integer);
var sx,sy:integer;
begin
    sx:=x*16;
    sy:=y*16;
	setfillstyle(1,110);
	bar(2+sx,7+sy, 7+sx,13+sy);
	bar(8+sx,8+sy,13+sx,14+sy);
	setcolor(185);
	line(3+sx,6+sy,7+sx, 6+sy);
	line(1+sx,8+sy,1+sx,12+sy);
	putpixel(2+sx, 7+sy,185) ;
	putpixel(2+sx,13+sy,185) ;
	line(3+sx,14+sy, 7+sx,14+sy) ;
	line(6+sx, 9+sy, 6+sx,13+sy);
	line(7+sx, 7+sy,12+sx, 7+sy);
	putpixel( 7+sx, 8+sy,185)  ;
	putpixel(13+sx, 8+sy,185)  ;
	putpixel(13+sx,14+sy,185)  ;
	line( 8+sx,15+sy,12+sx,15+sy);
	line(14+sx, 9+sy,14+sx,13+sy) ;
	setcolor(2);
	line(5+sx,5+sy,8+sx,2+sy) ;
	line(5+sx,2+sy,6+sx,2+sy) ;
	line(4+sx,0+sy,7+sx,0+sy) ;
	putpixel( 4+sx,1+sy,2)  ;
	putpixel( 8+sx,1+sy,2)  ;
	putpixel(10+sx,1+sy,2)  ;
	line( 9+sx,2+sy, 9+sx,6+sy) ;
	line(10+sx,3+sy,12+sx,3+sy) ;
	line(13+sx,2+sy,14+sx,1+sy) ;
	line(11+sx,0+sy,14+sx,0+sy) ;
	setcolor(45);
	line( 5+sx,1+sy, 7+sx,1+sy) ;
	line(11+sx,1+sy,13+sx,1+sy) ;
	line(10+sx,2+sy,12+sx,2+sy) ;
	putpixel(7+sx,2+sy,68)  ;
	setcolor(39);
	line(3+sx, 9+sy,3+sx,11+sy) ;
	line(4+sx,11+sy,4+sx,12+sy) ;
	line(8+sx,10+sy,8+sx,12+sy) ;
	line(9+sx,12+sy,9+sx,13+sy) ;
end;
procedure boardsegment(x,y:integer);
var sx,sy:integer;
begin
        sx:=x*16;
        sy:=y*16;
        if (x+y)mod 2 =0 then setfillstyle(1,214)
        else setfillstyle(1,216);
        bar(sx,sy,sx+16,sy+16);
end;

procedure drawsegment(x,y:integer);
var sx,sy:integer;
begin
        sx:=x*16;
        sy:=y*16;
        setfillstyle(1,18);
        bar(sx,sy,sx+15,sy+15);
        setfillstyle(1,141);
        bar(sx+2,sy+2,sx+13,sy+13);
        if effects then begin
           setfillstyle(1,71);
           bar(sx+2,sy+2,sx+7,sy+9);
           setfillstyle(1,15);
           bar(sx+2,sy+2,sx+4,sy+4);
        end;
        setfillstyle(1,215);
        bar(sx+4,sy+4,sx+11,sy+11);
        setfillstyle(1,18);
        bar(sx+5,sy+5,sx+10,sy+10);

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
   napr:=1;i:=3;j:=3; timer:=0 ;effects:=true;
   repeat

      if timer=18 then begin timer:=0; str(fps,fpss);OutTextXY(30,30,'fps='+fpss);fps:=0; end;
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


      if (i<0) or (i>19) or (j<0) or (j>11) then begin
         fillboard;
         napr:=random(4)+1;
         i:=random(20);
         j:=random(12);
      end
      else if fps=0 then begin
          ib:=random(20);
          jb:=random(12);
          drawbonus(ib,jb);
      end;


      if fps=0 then begin
      if (napr2>0) then begin
         napr:=napr2;
         napr2:=0;
      end;
      if napr=1 then i:=i+1
      else if napr=2 then j:=j+1
      else if napr=3 then i:=i-1
      else if napr=4 then j:=j-1;

      drawsegment(i,j);

      end;




   until k=#27;
   SetIntVec($1C,@SvInt1C);
   closegraph
end.
