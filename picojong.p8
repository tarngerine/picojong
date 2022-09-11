pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
t = 0
tiles={[0]="1m","2m","3m","4m","5m","6m","7m","8m","9m",
"1s","2s","3s","4s","5s","6s","7s","8s","9s",
"1p","2p","3p","4p","5p","6p","7p","8p","9p",
"e","s","w","n","r","g","w"}
tilespr={}
for k,v in pairs(tiles) do
  tilespr[v]=k
end
wall={}
nextTile=1
selTile=14
turn=1
state="hand"
players={
  {}, {}, {}, {}
}

function _init()
  genWall()
  for j=1,#players do
    players[j].hand = {}
  end
  for i=1,13*#players do
    add(players[((i-1)%4)+1].hand,wall[i])
  end
  nextTile = 13*#players+1
  for j=1,#players do
    sortHand(players[j].hand, function(a,b) return tilespr[a] > tilespr[b] end)
  end
end

function _draw()
  cls()
  map(0,3,0,0,128,64)

  if state == "wall" then
    cols=14
    for i,tile in pairs(wall) do
      local x = (i-1)%cols*8+8
      local y =flr((i-1)/cols)*12+6
      if i==nextTile then
        x = cos(t/60)*2 + x
        y = sin(t/60)*2 + y
        rectfill(x,y-1,x+8,y+8,12)
      end
      spr(tilespr[tile],x,y)
    end
    print("wall", -1, -1, 1)
    print("wall", 0, 0, 9)
  elseif state == "hand" then
    line(13,128-5,128-13,128-5,1)
    line(12,128-4,128-12,128-4,1)
    line(12,128-3,128-12,128-3,11)

    for i=#wall,1,-1 do
      if i > nextTile then
        if i <= 34 then 
          spr(45, 22 + (flr((i-1)/2) * 5), 128 - 23 + (i-1)%2 * 2)
        elseif i <= 68 then
          spr(46, 128-20, 128 - 24 - flr((i-34-1)/2)*5 + (i-1)%2 * 2) 
        elseif i <= 102 then
          spr(45, 128 - 26 - (flr((i-68-1)/2) * 5), 14 + (i-1)%2 * 2)
        else
          -- jump to reverse loop below for best draw order
        end
      end
    end
    for i=103,#wall do
      if i > nextTile then
        if i == #wall - 6 then
          sprr(tilespr[wall[i]], 12, 24 + flr((i-102-1)/2)*5 - 5, 1)
        else
          local offset = - ((i-1)%2) * 2 
          if i % 2 == 0 and i == nextTile + 1 then
            offset = 0
          end
          spr(46, 14, 24 + flr((i-102-1)/2)*5 + offset) 
        end
      end
    end

    for pi, p in pairs(players) do
      for i,tile in pairs(p.hand) do
        if pi == 1 then
          spr(tilespr[tile],(i-1)*8+12,128-12)
        elseif pi == 2 then
          sprr(tilespr[tile],128-12,-(i-1)*8+128-20, 0)
        elseif pi == 3 then
          spr(tilespr[tile],-(i*8)+128-12,4, 1, 1, true, true)
        elseif pi == 4 then
          sprr(tilespr[tile],3,(i-1)*8+12, 1)
        end
      end
    end
    sprr(tilespr[wall[nextTile]],64-3,128-12-9, 0)
    print("turn: " .. turn .. ", next: " .. nextTile, -1,-1, 1)
    print("turn: " .. turn .. ", next: " .. nextTile, 0,0, 9)
  end

  -- print("picojong", 128 - 32, 128 - 6, 1)
  -- print("picojong", 128 - 31, 128 - 5, 9)

  t += 1
end

function sprr(spridx,dx,dy,dir)
  local w = 8
  local h = 8
  local mx = spridx%16
  local my = flr(spridx/16)
  for i=0,w-1 do
    if dir == 0 then
      -- 90 deg ccw
      tline(dx+i,dy+h,dx+i,dy,mx,my+i/h)
    elseif dir == 1 then
      -- 90 deg cw
      tline(dx+w-i,dy,dx+w-i,dy+h,mx,my+i/h)
    end
  end
end

function _update()
  if btn(5) then
    state="wall"
  else
    state="hand"
  end
  if btn(0) and nextTile < #wall then
    nextTile+=1
  elseif btn(1) and nextTile>1 then
    nextTile-=1
  end
end

function genWall()
  for j=0,3 do
    for i=0,#tiles do
      add(wall,tiles[i])
    end
  end
  --shuffle
	for i = #wall, 2, -1 do
		local j = ceil(rnd(i))
		wall[i], wall[j] = wall[j], wall[i]
		j = ceil(rnd(i))
		wall[i], wall[j] = wall[j], wall[i]
	end
end

function sortHand(a, cmp)
  for i=1,#a do
    local j = i
    while j > 1 and cmp(a[j-1],a[j]) do
        a[j],a[j-1] = a[j-1],a[j]
    j = j - 1
    end
  end
end
__gfx__
00777770007777700077777000777770007f55500077f77000777770007777700077777000777770007777700077777000777770007777700077777000777770
0777777f0777777f0755555f0755555f0f55d77f0777577f0775775f0777577f0775777f077b337f0777377f0777377f0737773f0737773f0737373f0777877f
07ffffff0775557f0775557f0755755f07f5557f0755555f07f5557f0777f57f0755557f0733333f0777377f0777377f0737773f0737773f0737373f0777877f
0755555f07ffffff077fff7f075f7f5f07f5757f0775757f0f55777f07f5757f07f5757f0773337f0777b77f0777377f07b777bf07b787bf07b7b7bf0737373f
0777776f0755555f0755555f0755555f0755555f0f577f5f0775555f0f57775f0757755f0778777f0777377f0737773f0737773f0737873f0737373f07b7b7bf
0777777f0777777f0777777f0777777f0777777f0777777f0777777f0777777f0777777f0766666f0777377f0737773f0737773f0737773f0737373f0737373f
0722888f0722888f0722888f0722888f0722888f0722888f0722888f0722888f0722888f0769696f0777377f0737773f0737773f0737773f0737373f0737373f
00777770007777700077777000777770007777700077777000777770007777700077777000797970007777700077777000777770007777700077777000777770
007777700077777000777770007777700077777000777770007777700077777000f7777000777770007777700077f77000775770007777700077777000777770
0737773f07bf8f3f077ff77f0777f77f0775777f077f7f7f077f7f7f0775757f0757f77f07f5757f0757575f0775557f0775557f0755555f0775757f077f877f
0737373f07bf8f3f07f5557f077f577f0777777f0775757f0775757f077f7f7f077757ff0777777f0777777f077f5f7f077f5f7f0775757f07f5757f0788888f
0733733f0777777f0f58885f0777777f0777877f0777777f0777777f0777777f0777775f07f5757f0787878f0755555f0755555f0755555f0f55755f078f8f8f
07b777bf07bf8f3f0f58885f0777f77f0777777f077f7f7f0777877f0778787f0778787f07f5757f0777777f0755555f075d5d5f0755755f07f5757f0788888f
0733733f0777777f07f5557f077f577f0777757f0775757f0777777f0777777f0777777f0777777f0757575f0775557f07555f5f075f7f5f07f575ff077f877f
0737373f07bf8f3f077ff77f0777777f07777f7f0777777f0775757f0778787f0778787f07f5757f07f7f7ff0757575f0757555f07d555df0f57755f077f877f
00777770007777700077777000777770007777700077777000777770007777700077777000777770007777700077d770007777700077777000777770007777f0
00777770007777700044444444444444444444004233333333333333333333244233333333333333333333240077777000999990099900000999900000000000
0373373f0777777f0a22222222222222222222a04233333333333333333333244233333333333333333333240777777f09999994999940009999940000000000
0737f37f0777777f42553333333333333333552442333333333333333333332442333333333333333333332407ffffff09999994999940009999940000000000
0333333f0777777f4253333333333333333335244233333333333333333333244233333333333333333333240755555f09999994999940009999940000000000
0733337f0777777f4233333333333333333333244233333333333333333333244253333333333333333335240777776f099999949999400074444f0000000000
07733f7f0777777f4233333333333333333333244233333333333333333333244255333333333333333355240777777f099999947444f0000777f00000000000
073f333f0777777f4233333333333333333333244233333333333333333333240a22222222222222222222a00722888f09999994077f00000000000000000000
007777f0007777704233333333333333333333244233333333333333333333240044444444444444444444000077777000444440000000000000000000000000
__map__
2b0102030405060708090a0b0c0d0e0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
101112131415161718191a1b1c1d1e1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2223232323232323232323232323232400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2829292929292929292929292929292a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
