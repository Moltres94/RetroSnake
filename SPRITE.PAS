Unit sprite;
{--------------------------------}
Interface
	procedure fillboard;
	procedure drawbonus(var x,y:integer);
	procedure boardsegment(var x,y:integer);
	procedure drawsegment(var x,y:integer);
	procedure colorshift(x:integer);
	procedure pain;

{---------------------------------}
Implementation
    uses graph,crt;
	var color:integer;
		colors:array[1..10] of integer;
		
	procedure colorshift;
	begin
		color:=x;
	end;
	
	procedure fillboard;
	var wi,wj:integer;
	begin
			setfillstyle(1,216+color);
			bar(0,0,320,191);
			setfillstyle(1,214+color);
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

	procedure redberry(sx,sy:integer);
	begin
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
	
	procedure banana(sx,sy:integer);
	begin
		setcolor(43);
		line(2+sx,8+sy, 10+sx,8+sy) ;
		line(5+sx,11+sy, 10+sx,11+sy) ;
		
		setcolor(14);
		line(3+sx,7+sy, 11+sx,7+sy) ;
		line(5+sx,9+sy, 13+sx,9+sy) ;
		line(4+sx,10+sy, 12+sx,10+sy) ;
		line(12+sx,8+sy, 13+sx,8+sy) ;
		line(10+sx,6+sy, 11+sx,6+sy) ;
		putpixel(11+sx, 5+sy,14) ;
		putpixel(13+sx, 7+sy,14) ;
		
		setcolor(6);
		moveto(1+sx,8+sy);
		lineto(5+sx,12+sy);		lineto(10+sx,12+sy);
		lineto(11+sx,11+sy);	lineto(12+sx,11+sy);
		lineto(14+sx,9+sy);		lineto(14+sx,7+sy);
		lineto(12+sx,5+sy);		lineto(12+sx,7+sy);
		lineto(10+sx,9+sy);		lineto(6+sx,9+sy);
		lineto(3+sx,6+sy);		lineto(2+sx,6+sy);
		lineto(1+sx,7+sy);
		
		
		line(3+sx,9+sy,5+sx,7+sy);		line(5+sx,7+sy,8+sx,7+sy);
		line(8+sx,7+sy,11+sx,4+sy);		line(11+sx,4+sy,12+sx,4+sy);
		
		putpixel(2+sx, 7+sy,184) ;
		putpixel(4+sx, 9+sy,184) ;
		putpixel(13+sx, 4+sy,184) ;
		putpixel(14+sx, 5+sy,184) ;
	end;

	procedure drawbonus;
	var sx,sy,z:integer;
	begin
		sx:=x*16;
		sy:=y*16;
		z:=random(2);
		if z=1 then banana(sx,sy)
		else redberry(sx,sy);
	end;
	
	procedure boardsegment;
	var sx,sy:integer;
	begin
			sx:=x*16;
			sy:=y*16;
			if (x+y)mod 2 =0 then setfillstyle(1,214+color)
			else setfillstyle(1,216+color);
			bar(sx,sy,sx+15,sy+15);
	end;

	procedure drawsegment;
	var sx,sy:integer;
	begin
			sx:=x*16;
			sy:=y*16;
			setfillstyle(1,18);
			bar(sx,sy,sx+15,sy+15);
			setfillstyle(1,141+color);
			bar(sx+2,sy+2,sx+13,sy+13);
			{if effects then begin  }
			   setfillstyle(1,71+color);
			   bar(sx+2,sy+2,sx+7,sy+9);
			   setfillstyle(1,15);
			   bar(sx+2,sy+2,sx+4,sy+4);
			{end; }
			setfillstyle(1,215+color);
			bar(sx+4,sy+4,sx+11,sy+11);
			setfillstyle(1,18);
			bar(sx+5,sy+5,sx+10,sy+10);

	end;
	
	procedure pain;
	begin
	  Sound(494);  Delay(200);  NoSound;
	  NoSound;   Delay(200);  Sound(740);  Delay(200);  NoSound;
	  Sound(494);  Delay(200);  NoSound;
	  Sound(784);  Delay(200);  NoSound;
	  NoSound;   Delay(200);  Sound(740);  Delay(200);  NoSound;
	  Sound(659);  Delay(200);  NoSound;
	  Sound(740);  Delay(200);  NoSound;
	  NoSound;   Delay(200);  Sound(659);  Delay(200);  NoSound;
	  Sound(740);  Delay(200);  NoSound;
	  Sound(784);  Delay(200);  NoSound;
	  Sound(784);  Delay(200);  NoSound;
	  Sound(740);  Delay(200);  NoSound;
	  Sound(659);  Delay(200);  NoSound;
	  Sound(494);  Delay(200);  NoSound;
	  NoSound;
	end;
begin
   colors[1]:=216;
   colors[2]:=214;
end .