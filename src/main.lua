--[[
The MIT License

Copyright (C) 2021 Tony Wang

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

require 'libs/beParticles/beParticles'

Canvas.main:resize(128, 128)

local cos = function (x)
	return math.cos(x * -math.pi * 2)
end
local sin = function (x)
	return math.sin(x * -math.pi * 2)
end

local add = function (lst, elem, index)
	if index == nil then
		table.insert(lst, elem)
	else
		table.insert(lst, index, elem)
	end
end
local all = function (lst)
	local index = 0
	local count = #lst

	return function ()
		index = index + 1

		if index <= count then
			return lst[index]
		end
	end
end
local foreach = function (lst, pred)
	for _, elem in ipairs(lst) do
		pred(elem)
	end
end
local rectfill = function (x0, y0, x1, y1, col)
	rect(x0, y0, x1, y1, true, col)
end

local _t = nil
local t = function ()
	return _t
end

local _palettes = {
	Color.new(0,0,0,255),
	Color.new(29,43,83,255),
	Color.new(126,37,83,255),
	Color.new(0,135,81,255),
	Color.new(171,82,54,255),
	Color.new(95,87,79,255),
	Color.new(194,195,199,255),
	Color.new(255,241,232,255),
	Color.new(255,0,77,255),
	Color.new(255,163,0,255),
	Color.new(255,236,39,255),
	Color.new(0,228,54,255),
	Color.new(41,173,255,255),
	Color.new(131,118,156,255),
	Color.new(255,119,168,255),
	Color.new(255,204,170,255)
}
local C = function (index)
	return _palettes[index + 1]
end

local _sprites = {
	Resources.load('assets/sprite.spr')
}
local S = function (_)
	return _sprites[1]
end

--pico-ps particle system
--max kearney
--created: april 2019
--updated: october 2020
---------------------

-------------------------------------------------- globals
show_demo_info = true
show_dude = false
my_emitters = nil
emitter_type = 1
emitters = {"fire", "water spout", "rain", "stars", "explosion (burst)", "confetti (burst)", "space warp", "amoebas", "portal", "whirly bird", "spiral galaxy monster", "structures (mouse)", "structures (arrows)"}

global_angle = 0

-------------------------------------------------- demo code
-- these are functions to help the demo run. you can copy/model from here,
-- but most of this stuff isn't strictly necessary for an emitter to run
function draw_demo()
	foreach(my_emitters, function(obj) obj:draw() end)
	if (show_demo_info) then
		rectfill(0, 0, 128, 6, C(1))
		line(0, 7, 128, 7, C(2))
		rectfill(0, 91, 128, 128, C(1))
		line(0, 90, 128, 90, C(2))
		-- text("arrows: move emitters", 1, 92, C(6))
		-- text("z: start/stop emitters", 1, 98, C(6))
		-- text("q: show/hide info", 1, 104, C(6))
		-- text("f: next example", 1, 110, C(6))
		-- text("s: prev example", 1, 116, C(6))
		-- text("x: spawn emitter", 1, 122, C(6))
		-- text("num: "..get_all_particles(), 84, 110, C(15))
		--text("mem: "..stat(0), 84, 116, C(15))
		--text("cpu: "..stat(1), 84, 122, C(15))
		if (show_dude) then
			--text("😐♥", 113, 92, C(14))
		end
	else
		--text("by max kearney", 72, 122, C(5))
	end
	text(emitters[emitter_type], 1, 100, C(7))
end

function get_all_particles()
	local p_count = 0
	for i in all(my_emitters) do
		p_count = p_count + #i.particles
	end
	return p_count
end

function update_demo()
	for e in all(my_emitters) do
		e.update(e, delta_time)
		update_whirly_bird(e)
		update_hypno(e)
		update_warp(e)
		update_portal(e)
		update_structures(e)
		update_fire(e)
	end
	get_input()
end

function update_hypno(e)
	if (emitters[emitter_type] == "spiral galaxy monster" and (e == my_emitters[2] or e == my_emitters[3])) then
		update_angle(10)
		ps_set_angle(e, global_angle)
	end
end

function update_warp(e)
	if (emitters[emitter_type] == "space warp") then
		local p = rotate_around(5, Vec2.new(64, 64), e.pos)
		ps_set_pos(e, p.x, p.y)
	end
end

function update_portal(e)
	if (emitters[emitter_type] == "portal") then
		if (e == my_emitters[1]) then
			local p = rotate_around(5, Vec2.new(64, 60), e.pos)
			p = rotate_around(90, Vec2.new(64, 60), p)
			ps_set_pos(e, p.x, p.y)
		elseif(e == my_emitters[4]) then
			local p = rotate_around(6, Vec2.new(64, 66), e.pos)
			ps_set_pos(e, p.x, p.y)
		end
	end
end

function update_whirly_bird(e)
	if (emitters[emitter_type] == "whirly bird") then
		update_angle(5)
		ps_set_angle(e, global_angle)
		local p = rotate_janky(64, 64, 0.01, e.pos)
		ps_set_pos(e, p.x, p.y)
	end
end

function update_structures(e)
	if (emitters[emitter_type] == "structures (mouse)") then
		--ps_set_pos(e, stat(32), stat(33))
		local x, y = mouse()
		ps_set_pos(e, x, y)
	end
end

function update_fire(e)
	if (emitters[emitter_type] == "fire") then
		ps_set_angle(e, 90 + (sin(t() * e.flicker) * 27), e.p_angle_spread)
	end
end

function rotate_janky(ox, oy, angle, p)
	p.x = cos(angle) * (p.x-ox) - sin(angle) * (p.y-oy) + ox
	p.y = sin(angle) * (p.x-ox) + cos(angle) * (p.y-oy) + oy
	return p
end

function rotate_around(angle, c, p)
	angle = angle / 360 -- convert to 0-1
	local rotatedx = cos(angle) * (p.x - c.x) - sin(angle) * (p.y-c.y) + c.x
	local rotatedy = sin(angle) * (p.x - c.x) + cos(angle) * (p.y - c.y) + c.y
	return Vec2.new(rotatedx,rotatedy)
end

function update_angle(speed)
	global_angle = global_angle + speed
	if (global_angle > 360) then global_angle = 0 end
end

function get_input()
	-- if (btnp(5,1)) then
	-- 	if (show_demo_info) then show_demo_info = false
	-- 	else show_demo_info = true end
	-- end

	-- if (btnp(4, 0)) then
	-- 	if (my_emitters[1].is_emitting(my_emitters[1])) then
	-- 		for e in all(my_emitters) do
	-- 			e.stop_emit(e)
	-- 		end
	-- 	else
	-- 		for e in all(my_emitters) do
	-- 			e.start_emit(e)
	-- 		end
	-- 	end
	-- end
	-- if (btnp(5, 0)) then
	-- 	spawn_emitter(emitters[emitter_type])
	-- end

	-- local x = 0
	-- local y = 0
	-- if (btn(0,0)) then
	-- 	x =  -1
	-- elseif (btn(1,0)) then
	-- 	x = 1
	-- end
	-- if (btn(2,0)) then
	-- 	y = -1
	-- elseif (btn(3,0)) then
	-- 	y = 1
	-- end
	-- for e in all(my_emitters) do
	-- 	e.pos.x = e.pos.x + x
	-- 	e.pos.y = e.pos.y + y
	-- end

	-- if (btnp(4,1)) then
	-- 	show_dude = not show_dude
	-- end

	if (btnp(0)) then
		emitter_type = emitter_type - 1
		if (emitter_type < 1) then
			emitter_type = #emitters
		end
		my_emitters = {}
		spawn_emitter(emitters[emitter_type])
	elseif (btnp(1)) then
		emitter_type = emitter_type + 1
		if (emitter_type > #emitters) then
			emitter_type = 1
		end
		my_emitters = {}
		spawn_emitter(emitters[emitter_type])
	end
end

function spawn_emitter(emitter_string)
	-- here is an example of using the set functions to create an emitter
	if (emitter_string == "space warp") then
		-- create the emitter using x,  y,  frequency, max_p
		local warp = emitter.create(70, 70, 11, 520)
		-- the emitter.create() function has optional arguments
		-- set the stuff you want to change
		ps_set_speed(warp, 30, 200)
		ps_set_life(warp, 0.8)
		ps_set_size(warp, 0, 2, 0.5, 0)
		ps_set_colours(warp, {C(7), C(8), C(11), C(12), C(14)})
		ps_set_rnd_colour(warp, true)
		ps_set_pooling(warp, true)
		add(my_emitters, warp)
	elseif (emitter_string == "rain") then
		local rain = emitter.create(64, 12, 2, 200)
		ps_set_area(rain, 50, 10)
		ps_set_gravity(rain, true)
		ps_set_speed(rain, 0)
		ps_set_size(rain, 0)
		ps_set_life(rain, 1.5, 1)
		ps_set_sprites(rain, {S(91), S(92), S(93), S(94), S(95), S(96), S(97)})
		add(my_emitters, rain)
	elseif(emitter_string == "whirly bird") then
		local bird = emitter.create(80, 80, 1, 0)
		ps_set_sprites(bird, {S(22), S(23), S(25), S(27), S(28), S(29)})
		ps_set_life(bird, 3)
		ps_set_angle(bird, 0)
		add(my_emitters, bird)
	elseif(emitter_string == "spiral galaxy monster") then
		local warp = emitter.create(64, 64, 1, 0)
		ps_set_speed(warp, 30, 200)
		ps_set_life(warp, 0.8)
		ps_set_size(warp, 0, 2, 0.5, 0)
		ps_set_colours(warp, {C(7), C(6), C(5)})
		ps_set_area(warp, 10, 10)
		add(my_emitters, warp)
		local hypno = emitter.create(64, 64, 0.9, 0)
		ps_set_colours(hypno, {C(5), C(13), C(14), C(12), C(11)})
		ps_set_size(hypno, 0, 5)
		ps_set_angle(hypno, 0, 90)
		ps_set_life(hypno, 4)
		ps_set_speed(hypno, 12)
		add(my_emitters, hypno)
		cray = hypno.clone(hypno)
		ps_set_colours(cray, {C(15), C(14), C(12), C(11), C(10)})
		ps_set_rnd_colour(cray, true)
		ps_set_speed(cray, 15)
		ps_set_frequency(cray, 0.5)
		add(my_emitters, cray)
	elseif(emitter_string == "water spout") then
		local spout = emitter.create(110, 90, 1, 0, false, true)
		ps_set_colours(spout, {C(12), C(1)})
		ps_set_size(spout, 2, 0, 3)
		ps_set_angle(spout, 90, 45)
		ps_set_life(spout, 2, 2)
		ps_set_speed(spout, 100, 50)
		local spray = emitter.create(110, 90, 1, 0, false, true)
		ps_set_colours(spray, {C(7), C(6), C(5)})
		ps_set_angle(spray, 90, 45)
		ps_set_life(spray, 2, 2)
		ps_set_speed(spray, 100, 50)
		ps_set_size(spray, 0, 1)
		add(my_emitters, spray)
		add(my_emitters, spout)
		local explo = emitter.create(110, 90, 0.1, 0)
		ps_set_size(explo, 2, 0, 2, 0)
		ps_set_speed(explo, 10, 10, 10)
		ps_set_life(explo, 1, 1)
		ps_set_colours(explo, {C(7), C(6), C(5)})
		ps_set_area(explo, 20, 20)
		ps_set_angle(explo, 90, 45)
		add(my_emitters, explo)
	elseif(emitter_string == "stars") then
		local front = emitter.create(0, 64, 0.2, 0)
		ps_set_area(front, 0, 128)
		ps_set_colours(front, {C(7)})
		ps_set_size(front, 0)
		ps_set_speed(front, 34, 34, 10)
		ps_set_life(front, 3.5)
		ps_set_angle(front, 0, 0)
		add(my_emitters, front)
		local midfront = front.clone(front)
		ps_set_frequency(midfront, 0.15)
		ps_set_life(midfront, 4.5)
		ps_set_colours(midfront, {C(6)})
		ps_set_speed(midfront, 26, 26, 5)
		add(my_emitters, midfront)
		local midback = front.clone(front)
		ps_set_life(midback, 6.8)
		ps_set_colours(midback, {C(5)})
		ps_set_speed(midback, 18, 18, 5)
		ps_set_frequency(midback, 0.1)
		add(my_emitters, midback)
		local back = front.clone(front)
		ps_set_frequency(back, 0.07)
		ps_set_life(back, 11)
		ps_set_colours(back, {C(1)})
		ps_set_speed(back, 10, 10, 5)
		add(my_emitters, back)
		local special = emitter.create(64, 64, 0.2, 0)
		ps_set_area(special, 128, 128)
		ps_set_angle(special, 0, 0)
		ps_set_frequency(special, 0.01)
		ps_set_sprites(special, {S(78), S(79), S(80), S(81), S(82), S(83), S(84)})
		ps_set_speed(special, 30, 30, 15)
		ps_set_life(special, 1)
		add(my_emitters, special)
	elseif(emitter_string == "explosion (burst)") then
		local explo = emitter.create(64, 64, 0, 30)
		ps_set_size(explo, 4, 0, 3, 0)
		ps_set_speed(explo, 0)
		ps_set_life(explo, 1)
		ps_set_colours(explo, {C(7), C(6), C(5)})
		ps_set_area(explo, 30, 30)
		ps_set_burst(explo, true, 10)
		add(my_emitters, explo)
		local spray = emitter.create(64, 64, 0, 80)
		ps_set_size(spray, 0)
		ps_set_speed(spray, 20, 10, 20, 10)
		ps_set_colours(spray, {C(7), C(6), C(5)})
		ps_set_life(spray, 0, 1.3)
		ps_set_burst(spray, true, 30)
		add(my_emitters, spray)
		local anim = emitter.create(64, 64, 0, 18)
		ps_set_speed(anim, 0)
		ps_set_life(anim, 1)
		ps_set_sprites(anim, {S(32), S(33), S(34), S(35), S(36), S(37), S(38), S(39), S(40), S(40), S(40), S(41), S(41), S(41)})
		ps_set_area(anim, 30, 30)
		ps_set_burst(anim, true, 6)
		add(my_emitters, anim)
	elseif(emitter_string == "confetti (burst)") then
		local left = emitter.create(0, 90, 0, 50, true, true)
		ps_set_size(left, 0, 0, 2)
		ps_set_speed(left, 50, 50, 50)
		ps_set_colours(left, {C(7), C(8), C(9), C(10), C(11), C(12), C(13), C(14), C(15)})
		ps_set_rnd_colour(left, true)
		ps_set_life(left, 1, 1, 2)
		ps_set_angle(left, 30, 45)
		add(my_emitters, left)
		local right = left.clone(left)
		ps_set_angle(right, 105, 45)
		ps_set_pos(right, 128, 90)
		add(my_emitters, right)
	elseif(emitter_string == "portal") then
		local outer = emitter.create(96, 64, 2, 0)
		ps_set_speed(outer, 1, 1)
		ps_set_sprites(outer, {S(48), S(49), S(50), S(51)})
		ps_set_angle(outer, 180, 0)
		ps_set_life(outer, 2)
		add(my_emitters, outer)
		local sparks = emitter.create(64, 64, 0.05, 0, false, true)
		ps_set_sprites(sparks, {S(42), S(43), S(42), S(43), S(42), S(43), S(42), S(43)})
		ps_set_speed(sparks, 30, 30, 30)
		ps_set_life(sparks, 0.5, 1)
		ps_set_area(sparks, 15, 15)
		ps_set_angle(sparks, 0, 180)
		add(my_emitters, sparks)
		local matter = emitter.create(64, 64, 0.03, 0)
		ps_set_sprites(matter, {S(58), S(59), S(60), S(61), S(62), S(62), S(62), S(63), S(63), S(63)})
		ps_set_life(matter, 0.5, 0.6)
		ps_set_area(matter, 30, 30)
		add(my_emitters, matter)
		local spinner = emitter.create(64, 84, 0.4, 0)
		ps_set_life(spinner, 1, 1)
		ps_set_speed(spinner, 5)
		ps_set_colours(spinner, {C(6), C(5), C(1)})
		ps_set_size(spinner, 2, 0)
		ps_set_angle(spinner, 90)
		add(my_emitters, spinner)
		local center = emitter.create(64, 64, 1, 0)
		ps_set_size(center, 0)
		ps_set_colours(center, {C(7), C(12)})
		ps_set_rnd_colour(center, true)
		ps_set_life(center, 1)
		ps_set_speed(center, 35, -20)
		add(my_emitters, center)
	elseif(emitter_string == "structures (mouse)") then
		--poke(0x5f2d, 1)
		local struc = emitter.create(64, 64, 1, 0)
		ps_set_speed(struc, 0)
		ps_set_sprites(struc, {S(85), S(86), S(87), S(88), S(89), S(90)})
		ps_set_angle(struc, 180, 0)
		ps_set_life(struc, 5)
		add(my_emitters, struc)
	elseif(emitter_string == "structures (arrows)") then
		local struc = emitter.create(96, 64, 1, 125)
		ps_set_speed(struc, 0)
		ps_set_sprites(struc, {S(54), S(55), S(45), S(47)})
		ps_set_angle(struc, 180, 0)
		ps_set_life(struc, 2)
		add(my_emitters, struc)
		local structwo = struc.clone(struc)
		ps_set_pos(structwo, 32, 64)
		ps_set_sprites(structwo, {S(52), S(53), S(44), S(30)})
		add(my_emitters, structwo)
		local structhree = struc.clone(struc)
		ps_set_pos(structhree, 64, 32)
		ps_set_sprites(structhree, {S(56), S(57), S(46), S(31)})
		add(my_emitters, structhree)
	elseif(emitter_string == "amoebas") then
		local grav = emitter.create(84, 64, 0.3, 60)
		ps_set_speed(grav, 50, -50, 50, -50)
		ps_set_life(grav, 1, 1.5)
		ps_set_sprites(grav, {S(75), S(76), S(77), S(72), S(71), S(72), S(73), S(74)})
		ps_set_area(grav, 20, 110)
		ps_set_angle(grav, 180)
		ps_set_pooling(grav, true)
		add(my_emitters, grav)
	elseif(emitter_string == "fire") then
		local main = emitter.create(64, 64, 4, 110)
		ps_set_area(main, 5, 0)
		ps_set_colours(main, {C(8), C(9), C(10), C(5)})
		ps_set_speed(main, 15, 5, 20)
		ps_set_life(main, 0.5, 1)
		ps_set_angle(main, 90, 10)
		ps_set_size(main, 1.5, 0, 2, 0)
		main.flicker = 1.1
		add(my_emitters, main)
		local left = main.clone(main)
		ps_set_pos(left, 44, 60)
		left.flicker = 0.8
		add(my_emitters, left)
		local right = main.clone(main)
		ps_set_pos(right, 84, 60)
		right.flicker = 0.95
		add(my_emitters, right)
	end
end

function setup()
	print('beParticles v' .. beParticles.version)

	local now = DateTime.toSeconds(DateTime.ticks())
	prev_time = now
	delta_time = now-prev_time
	my_emitters = {}
	emitter_type = 1
	spawn_emitter(emitters[emitter_type])
end

function update(delta)
	_t = delta

	update_time()
	update_demo()

	cls()
	draw_demo()
end
