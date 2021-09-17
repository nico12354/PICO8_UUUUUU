pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--uuuuuu
--by mokonanico


--to do list :

--end title ???
--more platform
--music


//0 -> menu
//1 -> in game
//2 -> end title

state=0

function _init()
	create_player()
	create_stars()
	music(0)
end

function _update()

	if state == 0 then
		update_stars()
		update_menu()
	elseif state == 1 then
	 update_stars()
		update_player()
		update_checkpoint()
		update_destroyblocs()
		update_bounceblocs()
		update_laser()
		
	elseif state == 2 then
		
	end
	
end

function _draw()
	cls()
	
	
	if state == 0 then
	 draw_stars()
		draw_menu()
	elseif state == 1 then
		
		draw_stars()
		
		palt(0,false)
		mapx=flr(p.x/128)*16
		mapy=flr(p.y/128)*16
		map(mapx,mapy,0,0,16,16)
		palt(0,true)
		
		if(do_draw_p) draw_player()

	elseif state == 2 then
		
	end
	

	
end
-->8
--player
gravity=2
sx=7
sy=10
spawn_coord={x=sx*8,y=sy*8}

function create_player()
	p={x=spawn_coord.x,
				y=spawn_coord.y,
				sprite=1,
				speed=2,
				grav=1,
				dead=false}
	do_draw_p=true
end

function update_player()
	if p.dead then
		coresume(c_blink)
		return
	end
	
	newx=p.x
	newy=p.y

	--get the player input
	if(btn(⬅️)) newx-=p.speed
	if(btn(➡️)) newx+=p.speed

	--apply gravity
 newy+=gravity * p.grav
 
 --check collision and move
 --if there is no collision
 colx=check_col(newx,p.y,0)
 if not colx.c
 then
 	p.x=newx
 end 
 coly=check_col(p.x,newy,0)
 if not coly.c
 then
  p.y=newy
 end
 
 --check collision with deadly
 --object
 cdead=check_col(p.x,p.y,1)
 if cdead.c then
  --player is dead
 	p.dead=true
 	if(p.grav==1) p.sprite=17
 	if(p.grav==-1)p.sprite=18
 	sfx(4)
 	c_blink=cocreate(blink)
 end
 
 -- inverse gravity input
 cup=check_col(p.x,p.y-1,0) 
 cdown=check_col(p.x,p.y+1,0)
 
 if (cup.c or cdown.c) and              
     btnp(❎) then  
	 invert_grav()
	end
end

function draw_player()
	dx=p.x%128
	dy=p.y%128
	spr(p.sprite,dx,dy)
end

--check for a collision on one
--point. return obj with coord
--and if the collision append
--or not
function collision(_x,_y,flag)
	res={x=_x,y=_y,c=false}

	mapx=flr(_x/8)
	mapy=flr(_y/8)
	tile_spr=mget(mapx,mapy)
	
	--if it's a collision with a
	--wall i don't check the pixel
	if flag==0 then
		res.c=fget(tile_spr, flag)
		return res
	else 
		res.c=(pget(_x%128,_y%128) != 0 
		    and fget(tile_spr, flag))
		return res
	end
end

--return one of the collision
function check_col(x,y,flag)
	--top left
	col=collision(x+1,y,flag)
	if(col.c) return col
	--top right
	col=collision(x+6,y,flag)
	if(col.c) return col
	--bottow left
	col=collision(x+1,y+7,flag)
	if(col.c) return col
	--bottom right
	col=collision(x+6,y+7,flag)
	if(col.c) return col
	--middle
	col=collision(x+3,y+3,flag)
	if(col.c) return col
	col={x=0,y=0,c=false}
	return col
end

--coroutine to make the player
--blink
function blink()
	for i=1,6 do
		if(i%2==0) do_draw_p=false 
		if(i%2==1) do_draw_p=true
		for j=1,6 do
			yield()
		end
	end
	do_draw_p=true
	respawn_player()
end

--inverse the gravity of the
--player and change the spr
function invert_grav()
 if(p.grav==1)  sfx(0)
 if(p.grav==-1) sfx(1)  
	p.grav=p.grav*-1
	if p.sprite==1 then 
	 p.sprite=2
	else
		p.sprite=1
	end
	p.can_jump=false
end
-->8
--main menu
 	
function wait(a) 
 for i = 1,a do 
  flip() 
 end 
end

start_time=-1
function update_menu()
	if btn(❎) then 
		sfx(2)
		start_time=time()+0.6
	end
	if start_time != -1 and 
				time() > start_time then
		state=1
	end
end

function draw_menu()
 title="★ pppppp power up! ★"
 start="press ❎ to start"
	print(title,64-#title*2,34,12)
	print(start,64-#start*2,50,12)
end
-->8
--respawn point handler
last_check={x=-1,y=-1}

function respawn_player()
	if last_check.x==-1 then
		p.x=spawn_coord.x
		p.y=spawn_coord.y
	else 
		p.x=last_check.x
	 p.y=last_check.y
	end
	p.sprite=1
	p.grav=1
	p.dead=false
end

function set_checkpoint(x,y)
	--reset last check point sprite
	if last_check.x != -1 then
		mapx=flr(last_check.x/8)
  mapy=flr(last_check.y/8)
  mset(mapx,mapy,8)
	end
	last_check.x = x - (x%8)
	last_check.y = y - (y%8)
	mapx=flr(x/8)
 mapy=flr(y/8)
 mset(mapx,mapy,9)
 sfx(3)
end

function update_checkpoint()
	col=check_col(p.x,p.y,2)
	if col.c then
		set_checkpoint(col.x,col.y)
	end
end

-->8
--stars

function create_stars(n)
	stars={}
	for c=1,30 do
		new_star={x=0,y=0,c=0}
		new_star.x=rnd(128)
		new_star.y=rnd(128)
		if c>=20 then
			new_star.c=13
		else
			new_star.c=7
		end
		add(stars,new_star)
	end
end

function update_stars()
	for s in all(stars) do
		if s.c==13 then
			s.x-=1
		else
			s.x-=2
		end
	
		if s.x < 0 then
			s.x=128
			s.y=rnd(128)
		end
	end
end

function draw_stars()
	for s in all(stars) do
		pset(s.x,s.y,s.c)
	end
end
-->8
--destroying blocs

routines={}

function begin_destroy(x,y)
	mapx=flr(x/8)
	mapy=flr(y/8)
	add(routines,cocreate(co_destroy))
end

function update_destroyblocs()
	col=check_col(p.x,newy,3)
	if col.c then
		begin_destroy(col.x,col.y)
	end
	for r in all(routines) do
		coresume(r)
	end
end

--coroutine to destroy block
function co_destroy()
	local mx = mapx
	local my = mapy

	for i=1,3 do
		if(i==1)mset(mx,my,11)
		if(i==2)mset(mx,my,12)
		if(i==3)mset(mx,my,13)
		for j=1,12 do
			yield()
		end
	end
	mset(mx,my,0)
end
-->8
--bounce blocs

function begin_bounce()
	
end

function update_bounceblocs()
	col=check_col(p.x,newy,4)
	if col.c then
		invert_grav()
	end
end
-->8
--laser

function update_laser()
	mapx=flr(p.x/128)*16
	mapy=flr(p.y/128)*16
	for i=0,15 do
		for j=0,15 do
			tx=mapx+i
			ty=mapy+j
			tile=mget(tx,ty)
			if fget(tile,5) then
				if (time()%2) > 1 then
					if(tile==14)mset(tx,ty,30)
					if(tile==15)mset(tx,ty,31)
				else 
					if(tile==30)mset(tx,ty,14)
					if(tile==31)mset(tx,ty,15)
				end
			end
		end
	end
end
-->8
--force gravity blocs
__gfx__
000000000cccccc000c00c00111111110000000006777770000000000000000000dddd0000dddd00111111111111111110111111110111110000000000088000
000000000c0cc0c000c00c0010001101000670000677777000000777666000000d0666d00d0cccd0155555511555555110555551150555510000000000088000
007007000cccccc000cccc0010110011000670000677777000077777777660000d6000d00dc000d0155555511555555115055551150055510000000000088000
000770000cccccc000cccc0011001101006777000067770007777777777776600d0660d00d0cc0d0155555511555555115055500155050008888888800088000
0007700000cccc000cccccc010110011006777000067770006677777777777700d0006d00d000cd0155555511555555115555051100505518888888800088000
0070070000cccc000cccccc011001101067777700006700000066777777770000d6660d00dccc0d0155555511555555115505551005005510000000000088000
0000000000c00c000c0cc0c0101100010677777000067000000006667770000000d00d0000d00d00155555511555555115550551155500510000000000088000
0000000000c00c000cccccc011111111067777700000000000000000000000000dddddd00dddddd0111111111111111111110111111101010000000000088000
0000000008888880008008003333333311111111111111111000000011111111000000000000000033333333000000000000000000000000000000000000d000
00000000080880800080080030003303100000000000000110000000000000000000000000000000333333330000000000000000000000000000000000000000
00000000088888800088880030330033100000000000000110000000000000000000000000000000333333330000000000000000000000000000000000000000
0000000008888880008888003300330310000000000000011000000000000000000000000000000033333333000000000000000000000000d000000000000000
00000000008888000888888030330033100000000000000110000000000000000000000000000000333333330000000000000000000000000000d000000d0000
00000000008888000888888033003303100000000000000110000000000000000000000000000000333333330000000000000000000000000000000000000000
00000000008008000808808030330003100000000000000110000000000000000000000000000000333333330000000000000000000000000000000000000000
00000000008008000888888033333333100000000000000110000000000000000000000000000000333333330000000000000000000000000000000000000000
00000000000000000000000022222222100000000000000100000001000000000000000000000000111111112222222200000000000000000000000000000000
000000000000000000000000200022021000000000000001000000010000000000000000000000001c1111c12228822200000000000000000000000000000000
0000000000000000000000002022002210000000000000010000000100000000000000000000000011c11c112282282200000000000000000000000000000000
00000000000000000000000022002202100000000000000100000001000000000000000000000000111cc1112822228200000000000000000000000000000000
000000000000000000000000202200221000000000000001000000010000000000000000000000001c1111c12228822200000000000000000000000000000000
0000000000000000000000002200220210000000000000010000000100000000000000000000000011c11c112282282200000000000000000000000000000000
00000000000000000000000020220002100000000000000100000001000000000000000000000000111cc1112822228200000000000000000000000000000000
00000000000000000000000022222222111111111111111100000001111111110000000000000000111111112222222200000000000000000000000000000000
00000000000000000000000055555555000000000000000010000000000000010000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000050005505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000050550055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000055005505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000050550055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000055005505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000050550005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000055555555000000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31000000000000000000000000000000000000000000000000000000000000313131000031313131313131313131313131313100313100000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
31000000000000000000000000000000000000000000000000000000000000313100000000000000000000000000003131000000003100000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
310000000000000000000000000000000000000000000000000000000000003131a1a1a1a1a1a1a1a1a1a1a1a1a1a1a131000000003100000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
3100000000000000000000000000000000000000000000000000000000000031310000005000000000000000000000a131000000003100000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
3100000000000000000000000000000000000000000000000000000000000031310000000000000000000000000000a131000000003100000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
31000000000000000000000000000000000000000000000000000000000000313100000000000000000000000000000000000000003100000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000313100000000000000004000000000000000000000003100000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
300000000000000000000000000000000000000000000000000000000000003131a1a1a1a1a1a1a1a1a1a1a1a1a1a1a131313131313100000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
__gff__
0000000102020202040009010101222200000001000000000000110000002020000000010000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303031313131313131313131313131313131303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0332323232342727272727272727270303000000000000050500000000000003030505050505050505050505050505031300000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
0332323234250000000000000000000000000000000000000000000000000003030000000000000000000000000000031313000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
0332323425000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
0332342500000000000000000303030303030004040000000000000404000000000800000000000303000000000000000008000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
0334250000000000000000002435380303030303030303030303030303030303030300000000000000000000000000031313000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
03260000000000000000000000243503032b00001a1a1a1a1a1a1a1a00002a03030000000000000000000000000000031300000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
03260000000000000000000000001603032b0000000000000000000000002a03030000000000000000000000000000031300000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
03260000000000000000000000001600002b0000000000000000000000002a03030000000000000000000000000000031300000404130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
03260000000000000000000000001603032b0000000000000000000000002a03030000000000000000000000000000031300001313130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
03371500000000000000000000143603032b0000000000000000000000002a03030000030300000000000003030000031300001313130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
03383715000003030303000014363803032b00000a0a0a0a0a0a000000002a03030000000000000000000000000000031300000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
03383837150000030300001436383803032b000000000000000a0a0a00002a03030000000000000000000000000000031300000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
03383838371500030300143638383803032b0000000000000000000000002a03030000000000000000000000000000031300000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
03383838383715030314363838383803032b00001a1a1a1a1a1a1a1a00002a03030404040404040404040404040404031304040000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
0303030303030303030303030303030303030000030303030303030300000303030303030303030303030303030303031313130000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
1313131313131313131313131313131313130000131313131313131300001313131313131313131313131313131313131313130000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
1300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000131300000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
1300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000131300000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
1300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000131300000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
1300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000131300000404130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
1300000000000000000000000000000000000000000000000000000000000013130000000000000000000000000000131300001313130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
1300000000000000000000000000000000000000000000000000000000000013130000000000000000000000000000131300001313130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
1300000000000000000000000000000000000000000000000000000000000013130000000000000000000000000000131300000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
1300000000000000000000000000000000000000000000000000000000000013130000000000000000000000000000131304000404130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
1300000000000000000000000000000000000000000000000000000000000013130000000000000000000000000000131313001313130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
1300000000000000000000000000000000000000000000000000000000000013130000000000000000000000000000131300000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
1300000000000000000000000000000000000000000000000000000000000013130000000000000000000000000000131300000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
1300000000000000000000000000000000000000000000000000000000000013130000000000000000000000000000131300000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
1300000000000000000000000000000000000000000000000000000000000013130000000000000000000000000000131300000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
1300000000000000000000000000000000000000000000000000000000000013130000000000000000000000000000131304040004130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
1300000000000000000000000000000000000000000000000000000000000013131300001313131313131313131313131313130013130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
__sfx__
010300001005011050130501505036000360003500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300001305011050100500e05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700000c05010050130501505017050170501705017050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050400001c7501f750007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
031000000c21100201002010020100201002010020100201002010020100201002010020100201002010020100201002010020100201002010020100201002010020100201002010020100201002010020100001
112000001002210022100221002210022100221002210022110211102211022110221102211022110221102213021130221302213022130221302213022130221102111022110221102211022110221102211022
6b200000106252b6250000500005106252b62500005000052862500005000050000528625000050000500005106252b6250000500005106252b62500005000052962500005000052962529625000050000500005
__music__
03 05464344

