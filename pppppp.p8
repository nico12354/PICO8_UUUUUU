pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--uuuuuu
--by mokonanico


--to do list :

--advanced collision (check
-- pixel color)
--respawn point
--end title
--more platform
--music


//0 -> menu
//1 -> in game
//2 -> end title
state=0

function _init()
	create_player()
	create_stars()
end

function _update()

	if state == 0 then
		update_stars()
		update_menu()
	elseif state == 1 then
	 update_stars()
		update_player()
		update_checkpoint()
		if(p.dead)coresume(c_blink)
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
	if(p.dead) return

	newx=p.x
	newy=p.y

	//get the player input
	if(btn(⬅️)) newx-=p.speed
	if(btn(➡️)) newx+=p.speed

	//apply gravity
 newy+=gravity * p.grav
 
 //check collision and move
 //if there is no collision
 if not check_col(newx, p.y,0)
 then
 	p.x=newx
 end 
 if not check_col(p.x,newy,0)
 then
  p.y=newy
 end
 
 // check collision with deadly
 // object
 if check_col(p.x,p.y,1) then
 	// dead
 	p.dead=true
 	if(p.grav==1) p.sprite=17
 	if(p.grav==-1)p.sprite=18
 	sfx(4)
 	c_blink=cocreate(blink)
		
 end
 
 if (check_col(p.x,p.y-1,0) or
 				check_col(p.x,p.y+1,0)) and              
     btnp(❎) then 
  if(p.grav==1)  sfx(0,0)
  if(p.grav==-1) sfx(1,1)   
	 invert_grav()
	end
 
end

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

function draw_player()
	dx=p.x%128
	dy=p.y%128
	spr(p.sprite,dx,dy)
end

function collision(x,y,flag)
	mapx=flr(x/8)
	mapy=flr(y/8)
	tile_spr=mget(mapx,mapy)
	
	if flag==0 then
		return fget(tile_spr, flag)
	else 
		return 
		 pget(x%128,y%128) != 0 and
	  fget(tile_spr, flag)
	end
end

function check_col(x,y,flag)
	return collision(x,y,flag) or
								collision(x+7,y,flag) or
								collision(x,y+7,flag) or
								collision(x+7,y+7,flag) or
								collision(x+3,y+3,flag)
end

function invert_grav()
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
 if collision(p.x,p.y,2) then
 	set_checkpoint(p.x,p.y)
 end
 if collision(p.x+7,p.y,2) then
 	set_checkpoint(p.x+7,p.y)
 end
 if collision(p.x+3,p.y,2) then
 	set_checkpoint(p.x+3,p.y)
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
__gfx__
000000000cccccc000c00c00111111110000000006777770000000000000000000dddd0000dddd00000000000000000000000000000000000000000000000000
000000000c0cc0c000c00c0010001101000670000677777000000777666000000d0666d00d0cccd0000000000000000000000000000000000000000000000000
007007000cccccc000cccc0010110011000670000677777000077777777660000d6000d00dc000d0000000000000000000000000000000000000000000000000
000770000cccccc000cccc0011001101006777000067770007777777777776600d0660d00d0cc0d0000000000000000000000000000000000000000000000000
0007700000cccc000cccccc010110011006777000067770006677777777777700d0006d00d000cd0000000000000000000000000000000000000000000000000
0070070000cccc000cccccc011001101067777700006700000066777777770000d6660d00dccc0d0000000000000000000000000000000000000000000000000
0000000000c00c000c0cc0c0101100010677777000067000000006667770000000d00d0000d00d00000000000000000000000000000000000000000000000000
0000000000c00c000cccccc011111111067777700000000000000000000000000dddddd00dddddd0000000000000000000000000000000000000000000000000
00000000088888800080080033333333555555555555555511111115511111110000000000000000000000000000000000000000000000000000000000000000
00000000080880800080080030003303511111151111111111111115511111110000000000000000000000000000000000000000000000000000000000000000
00000000088888800088880030330033511111151111111111111115511111110000000000000000000000000000000000000000000000000000000000000000
00000000088888800088880033003303511111151111111111111115511111110000000000000000000000000000000000000000000000000000000000000000
00000000008888000888888030330033511111151111111111111115511111110000000000000000000000000000000000000000000000000000000000000000
00000000008888000888888033003303511111151111111111111115511111110000000000000000000000000000000000000000000000000000000000000000
00000000008008000808808030330003511111151111111111111115511111110000000000000000000000000000000000000000000000000000000000000000
00000000008008000888888033333333555555551111111111111115511111110000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000022222222111111115555555555555555000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000020002202111111115111111111111115000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000020220022111111115111111111111115000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000022002202111111115111111111111115000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000020220022111111115111111111111115000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000022002202111111115111111111111115000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000020220002111111115111111111111115000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000022222222555555555111111111111115000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000055555555111111115111111111111115000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000050005505111111115111111111111115000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000050550055111111115111111111111115000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000055005505111111115111111111111115000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000050550055111111115111111111111115000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000055005505111111115111111111111115000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000050550005111111115111111111111115000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000055555555111111115555555555555555000000000000000000000000000000000000000000000000000000000000000000000000
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
31000000000000000000000000000000000000000000000000000000000000313100000000000000000000000000003131000000003100000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
31000000000000000000000000000000000000000000000000000000000000313100000000000000000000000000003131000000003100000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
31000000000000000000000000000000000000000000000000000000000000313100000000000000000000000000003131000000003100000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
31000000000000000000000000000000000000000000000000000000000000313100000000000000000000000000000000000000003100000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000313100000000000000000000000000000000000000003100000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000313131313131313131313131313131313131313131313100000000000000000000
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
0000000102020202040000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303031313131313131313131313131313131303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0303030303030000000000000000000303000000000000050500000000000003030505050505050505050505050505031300000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
0303030303000000000000000000000000000000000000000000000000000003030000000000000000000000000000031313000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
0303030300000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
0303030000000000000000000303030303030004040000000000000404000000000800000000000303000000000000000008000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
0303000000000000000000000003030303030303030303030303030303030303030300000000000000000000000000031313000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
0300000000000000000000000003030303000000000000000000000000000003030000000000000000000000000000031300000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
0300000000000000000000000000030303000000000000000000000000000003030000000000000000000000000000031300000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
0300000000000000000000000000000303000000000000000000000000000003030000000000000000000000000000031300000404130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
0300000000000000000000000000000303000000000000000000000000000003030000000000000000000000000000031300001313130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
0303000000000000000000000000030303000000000000000000000000000003030000030300000000000003030000031300001313130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
0303030000000303030300000003030303000000000000000000000000000003030000000000000000000000000000031300000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
0303030300000003030000000303030303000000000000000000000000000003030000000000000000000000000000031300000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
0303030303000003030000030303030303000000000000000000000000000003030000000000000000000000000000031300000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
0303030303030003030003030303030303000000000000000000000000000003030404040404040404040404040404031304040000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003
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
011000000c21100201002010020100201002010020100201002010020100201002010020100201002010020100201002010020100201002010020100201002010020100201002010020100201002010020100001
