pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
t = 0
tiles={[0]="1m","2m","3m","4m","5m","6m","7m","8m","9m",
"1s","2s","3s","4s","5s","6s","7s","8s","9s",
"1p","2p","3p","4p","5p","6p","7p","8p","9p",
"e","s","w","n","r","g","wh"}
tilespr={}
for k,v in pairs(tiles) do
  tilespr[v]=k
end
wall={}
nextTile=1
selTile=14
turn=1
state="play"
doras=1
players={
  {}, {}, {}, {}
}
cpuChoice=""

function _init()
  printh("new game", "log.txt", true)
  genWall()
  for j=1,#players do
    players[j].hand = {}
    players[j].discards = {}
    players[j].melds = {}
    players[j].points = 350
  end
  -- draw and sort 13 tiles for each player
  for i=1,13*#players do
    add(players[((i-1)%4)+1].hand,wall[i])
  end
  for j=1,#players do
    sortHand(players[j].hand, function(a,b) return tilespr[a] > tilespr[b] end)
  end
  nextTile = 13*#players+1
end

function _draw()
  cls()
  local currentPlayer = (turn-1) % 4 + 1

  if state == "wall" then
    cols=13
    rectfill(0,0,128,128,3)
    for i,tile in pairs(wall) do
      local x = (i-1)%cols*8 + 12
      local y =flr((i-1)/cols)*9+14
      if i==nextTile then
        x = cos(t/60)*2 + x
        y = sin(t/60)*2 + y
        rectfill(x,y-1,x+8,y+8,12)
      end
      if i < nextTile or i > #wall - 14 then
        pal(7,15)
      end
      spr(tilespr[tile],x,y)
      pal(7,7)
    end
    for pi, p in pairs(players) do
      drawHands(pi, p, currentPlayer, true)
    end
    print("wall", -1, -1, 1)
    print("wall", 0, 0, 9)

  elseif state == "play" then
    map(0,3,0,0,128,64)
    -- "deck"/shadow tiles are on
    line(13,128-5,128-13,128-5,1)
    line(12,128-4,128-12,128-4,1)
    line(12,128-3,128-12,128-3,4)

    -- bottom right top walls
    for i=#wall,1,-1 do
      if i > nextTile then
        if i <= 34 then 
          spr(45, 22 + (flr((i-1)/2) * 5), 128 - 23 + (i-1)%2 * 2)
        elseif i <= 68 then
          spr(61, 128-20, 128 - 24 - flr((i-34-1)/2)*5 + (i-1)%2 * 2) 
        elseif i <= 102 then
          spr(45, 128 - 26 - (flr((i-68-1)/2) * 5), 14 + (i-1)%2 * 2)
        else
          -- jump to reverse loop below for best draw order
        end
      end
    end
    -- left wall
    for i=103,#wall do
      if i > nextTile then
        -- dora indicators
        if i % 2 == 0 and i >= #wall - 2 - doras * 2 and i < #wall - 2 then
          local y =24 + flr((i-103)/2)*5 + flr((i - #wall - 2 - doras * 2)/2)*2 + doras * 2 
          sprr(tilespr[wall[i]], 12, y, 1)
          line(12+2, y+8, 12+6, y+8, 4) -- shadow
        else
          -- due to draw order we have to push top tile "down" onto the table
          -- on the left wall
          local offset = - ((i-1)%2) * 2 
          if i % 2 == 0 and i == nextTile + 1 then
            offset = 0
          end
          spr(61, 14, 24 + flr((i-103)/2)*5 + offset) 
        end
      end
    end

    -- discards
    for i=1,#players[1].discards do
      spr(tilespr[players[1].discards[i]], 
        64-6*3 - 1 + (i-1)%6 * 6,
        64+6*3 + flr((i-1)/6) * 8)
    end
    for i=1,#players[2].discards do
      sprr(tilespr[players[2].discards[i]], 
        64+6*3 + flr((i-1)/6) * 8,
        64+6*3 - 8 - (i-1)%6 * 6, 0)
    end
    for i=1,#players[3].discards do
      spr(tilespr[players[3].discards[i]], 
        64+ 6*3 - 4 - (i-1)%6 * 6,
        64-6*3 - 8 - flr((i-1)/6) * 8, 1, 1, true, true)
    end
    for i=1,#players[4].discards do
      sprr(tilespr[players[4].discards[i]], 
        64-6*3 - 9 - flr((i-1)/6) * 8,
        64-6*3 - 1 + (i-1)%6 * 6, 1)
    end


    -- draw hands and points
    for pi, p in pairs(players) do
      pal(7, 1)
      pal(15, 1)
      pal(5, 7)
      if pi == 1 then
        print(p.points, 64-5, 64+8, 10)
        if currentPlayer == 1  then
          line(64-5, 64+8+6, 64+5, 64+8+6, t % 60 > 30 and 9 or 10)
        end
        spr(27, 64 - 16, 64 + 7)
      elseif pi == 2 then
        print(p.points, 64+2, 64-2, 10)
        if currentPlayer == 2 then
          line(64+8+6, 64-5, 64+8+6,64+5, t % 60 > 30 and 9 or 10)
        end
        sprr(28, 64 + 7, 64 + 7, 0)
      elseif pi == 3 then
        print(p.points, 64-5, 64-12, 10)
        if currentPlayer == 3 then
          line(64-5, 64-8-7, 64+5, 64-8-7, t % 60 > 30 and 9 or 10)
        end
        spr(29, 64 + 8, 64 - 15, 1, 1, true, true)
      elseif pi == 4 then
        print(p.points, 64- 13, 64-2, 10)
        if currentPlayer== 4 then
          line(64-8-7, 64-5, 64-8-7, 64+5, t % 60 > 30 and 9 or 10)
        end
        sprr(30, 64 - 16, 64 - 16, 1)
      end
      pal(7, 7)
      pal(5, 5)
      pal(15, 15)
      drawHands(pi, p, currentPlayer, true)
    end

    if (cpuChoice != "") then
      print("" .. cpuChoice, -1, 128-6, 1)
      print("" .. cpuChoice .. "", 0, 128-5, 7)
    end
  end

  t += 1
end

function drawHands(pi, p, currentPlayer, showTiles)
  -- drawn tile
  local selFloat = sin(t/60)*1 - 1.5
  local pad = showTiles and 1 or 4

  if currentPlayer == 1 then
    if selTile == 14 then
      sprr(tilespr[wall[nextTile]], 64-3, 128-12-4 - pad + selFloat, 0)
      spr(59, 64 - 1, 128 - 12 - 4 - 5 - pad + selFloat) -- hand 
    else
      sprr(tilespr[wall[nextTile]],64-3,128-12-5 - pad, 0)
    end
  end
  for i,tile in pairs(p.hand) do
    local tileOrSide = showTiles and tilespr[tile] or 47
    if pi == 1 then
      local y = 128-8 - pad
      local x = (i-1)*8+12
      if i == selTile then
        y += selFloat
        spr(tilespr[tile], x, y )
        spr(59, x + 2, y - 6) -- hand
      else
        spr(tilespr[tile],x,y)
      end
    elseif pi == 2 then
      if currentPlayer == 2 then sprr(46, 128-13-pad, 59, 0) end
      sprr(tileOrSide, 128-8-pad,-(i-1)*8+128-20, 0)
    elseif pi == 3 then
      if currentPlayer == 3 then spr(46, 59, pad + 1 + 4, 1, 1, true, true) end
      spr(tileOrSide, -(i*8)+128-12,pad, 1, 1, true, true)
    elseif pi == 4 then
      if currentPlayer == 4 then sprr(46, pad  + 4, 128 - 59,1) end
      sprr(tileOrSide, pad - 1,(i-1)*8+12, 1)
    end
  end
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

baseState = state
takeTurnDelay = 0
function _update()
  if btn(5) then
    state = "wall"
  else
    state = baseState
  end
  if btnp(1) then
    selTile=(selTile - 1 + 1) % 14 + 1
  elseif btnp(0) then
    selTile=(selTile -1  -1) % 14 + 1
  end

  -- play loop
  if state == "play" then
    local currentPlayer = (turn-1) % 4 + 1
    -- cpu discard
    if currentPlayer != 1 then
      takeTurnDelay += 1
      if takeTurnDelay > 15 then
        local discardIdx = decideDiscard(currentPlayer)
        if (discardIdx < 14) then
          -- discard the tile with the lowest use count
          add(players[currentPlayer].discards, players[currentPlayer].hand[discardIdx])
          players[currentPlayer].hand[discardIdx] = wall[nextTile]
        else
          -- discard the drawn tile
          add(players[currentPlayer].discards, wall[nextTile])
        end
        
        sortHand(players[currentPlayer].hand, function(a,b) return tilespr[a] > tilespr[b] end)
        -- takeTurnDelay = 0
        -- advance
        turn += 1
        nextTile+=1
        -- end game
        if nextTile == #wall - 14 then
          baseState = "end"
        end
      end
    end
    -- press discard
    if btnp(4) and currentPlayer == 1 then
      local cpuDiscardIdx = decideDiscard(1)
      cpuChoice = cpuDiscardIdx < 14 and players[1].hand[cpuDiscardIdx] or wall[nextTile]
      if selTile < 14 then
        add(players[1].discards, players[1].hand[selTile])
        players[1].hand[selTile] = wall[nextTile]
      else
        add(players[1].discards, wall[nextTile])
      end
      sortHand(players[1].hand, function(a,b) return tilespr[a] > tilespr[b] end)
      
      -- advance
      selTile = 14
      turn += 1
      nextTile+=1
      -- end game
      if nextTile == #wall - 14 then
        baseState = "end"
      end
    end
  end


  -- if btn(2) and nextTile < #wall then
  --   nextTile+=1
  -- elseif btn(3) and nextTile>1 then
  --   nextTile-=1
  -- end
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

function decideDiscard(currentPlayer)
  -- basic discard ai
  -- make pseudo melds, every combination thats possible
  -- then pick the tile that occurs the least in the pseudo melds
  local melds = {}
  local useCounts = {}
  local hand = table.copy(players[currentPlayer].hand)
  add(hand, wall[nextTile]) -- add wall tile as part of evaluation
  for i=1,#hand do
    useCounts[i] = 0
  end
  for i=1,#hand do
    for j=i+1,#hand do
      local tile1idx = tilespr[hand[i]]
      local tile2idx = tilespr[hand[j]]
      local isSameSuite = tile1idx < 27 and tile2idx < 27 and sub(hand[i], 2,2) == sub(hand[j], 2,2)

      -- make a pseudomeld of 2 tiles if the tiles are ryanmen, kanchan, or penchan or the same tile
      if tile1idx == tile2idx then
        add(melds, {tile1idx, tile2idx})
        useCounts[i] += 2
        useCounts[j] += 2
      elseif isSameSuite and tile1idx == tile2idx - 1 then
        add(melds, {tile1idx, tile2idx})
        useCounts[i] += 2
        useCounts[j] += 2
      elseif isSameSuite and tile1idx == tile2idx - 2 then
        add(melds, {tile1idx, tile2idx})
        useCounts[i] += 1
        useCounts[j] += 1
      end
      
      for k=j+1,#hand do
        local tile3idx = tilespr[hand[k]]
        isSameSuite = isSameSuite and tile3idx < 27  and sub(hand[i], 2,2) == sub(hand[k], 2,2)

        -- make full 3 tile melds, either straight or triplet
        -- add counter for each tile in the hand that is in the meld
        local meld = {}
        if tile1idx == tile2idx and tile2idx == tile3idx then
          meld = {tile1idx, tile2idx, tile3idx}
          useCounts[i] += 3
          useCounts[j] += 3
          useCounts[k] += 3
        elseif isSameSuite and tile1idx == tile2idx - 1 and tile2idx == tile3idx - 1 then
          meld = {tile1idx, tile2idx, tile3idx}
          useCounts[i] += 3
          useCounts[j] += 3
          useCounts[k] += 3
        end
        if #meld > 0 then
          add(melds, meld)
        end
      end
    end
  end
  printh("", "log.txt")
  printh("player" .. currentPlayer .. " hand: ", "log.txt")
  local handStr = ""
  for i=1,#hand do
    if #hand[i] < 2 then handStr ..= " " end
    handStr = handStr .. " " .. hand[i]
  end
  printh(handStr, "log.txt")
  -- find the useCount index with the lowest count
  local lowestCount = 999
  local lowestCountIdx = 1
  for i=1,#useCounts do
    if useCounts[i] <= lowestCount and tilespr[hand[i]] > tilespr[hand[lowestCountIdx]] then -- prefer to discard tiles with higher tilespr (e.g. honors)
      lowestCount = useCounts[i]
      lowestCountIdx = i
    end
  end
  -- printh("useCounts: ", "log.txt")
  local useCountsStr = ""
  for i, count in pairs(useCounts) do
    if count < 10 then
      useCountsStr = useCountsStr .. " "
    end
    useCountsStr = useCountsStr .. " " .. count
  end
  printh(useCountsStr, "log.txt")
  local lowestCountStr = ""
  for i=1, lowestCountIdx + 1 do
  if i == lowestCountIdx then
    lowestCountStr = lowestCountStr .. " " ..  " X"
    else 
    lowestCountStr = lowestCountStr .. "   "
    end
  end
  printh(lowestCountStr, "log.txt")

  printh("melds: ", "log.txt")
  local meldsStr = ""
  for meld in all(melds) do
  if meld[3] != nil then
    meldsStr = meldsStr .. tiles[meld[1]] .. "" .. tiles[meld[2]] .. "" .. tiles[meld[3]] .. " "
    else
    meldsStr = meldsStr .. tiles[meld[1]] .. "" ..tiles[meld[2]] .. " "
    end
  end
  printh("  ".. meldsStr, "log.txt")
  return lowestCountIdx
end

-- https://stackoverflow.com/questions/640642/how-do-you-copy-a-lua-table-by-value
table = {}
function table.copy(t)
  local u = { }
  for k, v in pairs(t) do u[k] = v end
  return setmetatable(u, getmetatable(t))
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
00777770007777700044444444444444444444004233333333333333333333244233333333333333333333240077777000999990099900000000000000000000
0373373f0777777f0a22222222222222222222a04233333333333333333333244233333333333333333333240777777f09999994999940000000000000000000
0737f37f0777777f42553333333333333333552442333333333333333333332442333333333333333333332407ffffff09999994999940000000000000000000
0333333f0777777f4253333333333333333335244233333333333333333333244233333333333333333333240755555f09999994999940000000000000000000
0733337f0777777f4233333333333333333333244233333333333333333333244253333333333333333335240777776f09999994999940004999999404999994
07733f7f0777777f4233333333333333333333244233333333333333333333244255333333333333333355240777777f099999947444f000f777777f0f77777f
073f333f0777777f4233333333333333333333244233333333333333333333240a22222222222222222222a00722888f09999994077f0000f777777f0f77777f
007777f000777770423333333333333333333324423333333333333333333324004444444444444444444400007777700044444000000000f777777f0f77777f
00000000000000000444444444444444444444404111111111111111111111144111111111111111111111140001111000000000099990000000000000000000
00000000000000004a11111111111111111111a44111111111111111111111144111111111111111111111140017777700000000999994000000000000000000
00000000000000004111111111111111111111144111111111111111111111144111111111111111111111140177777700000000999994000000000000000000
00000000000000004111111111111111111111144111111111111111111111144111111111111111111111141777d77700000000999994000000000000000000
000000000000000041111111111111111111111441111111111111111111111441111111111111111111111417ddd7770000000074444f000000000000000000
00000000000000004111111111111111111111144111111111111111111111144111111111111111111111141dd17710000000000777f0000000000000000000
00000000000000004111111111111111111111144111111111111111111111144a11111111111111111111a40001710000000000000000000000000000000000
00000000000000004111111111111111111111144111111111111111111111140444444444444444444444400001100000000000000000000000000000000000
__map__
2b0102030405060708090a0b0c0d0e0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
101112131415161718191a1b1c1d1e1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20210000000000000000000000002e2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2223232323232323232323232323232400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626263233333426262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626263536363726262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626263536363726262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626263839393a26262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2829292929292929292929292929292a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
