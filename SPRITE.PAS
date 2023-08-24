Unit sprite;
{--------------------------------}
Interface
	procedure fillboard;
	procedure drawbonus(var x,y:integer);
	procedure boardsegment(var x,y:integer);
	procedure drawsegment(var x,y:integer);

{---------------------------------}
Implementation
              uses graph;
	procedure fillboard;
	var wi,wj:integer;
	begin
			setfillstyle(1,216);
			bar(0,0,320,191);
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

	procedure drawbonus;
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

	procedure boardsegment;
	var sx,sy:integer;
	begin
			sx:=x*16;
			sy:=y*16;
			if (x+y)mod 2 =0 then setfillstyle(1,214)
			else setfillstyle(1,216);
			bar(sx,sy,sx+16,sy+16);
	end;

	procedure drawsegment;
	var sx,sy:integer;
	begin
			sx:=x*16;
			sy:=y*16;
			setfillstyle(1,18);
			bar(sx,sy,sx+15,sy+15);
			setfillstyle(1,141);
			bar(sx+2,sy+2,sx+13,sy+13);
			{if effects then begin  }
			   setfillstyle(1,71);
			   bar(sx+2,sy+2,sx+7,sy+9);
			   setfillstyle(1,15);
			   bar(sx+2,sy+2,sx+4,sy+4);
			{end; }
			setfillstyle(1,215);
			bar(sx+4,sy+4,sx+11,sy+11);
			setfillstyle(1,18);
			bar(sx+5,sy+5,sx+10,sy+10);

	end;
end.