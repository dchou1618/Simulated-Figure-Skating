globals [prof_falls hockey_falls beginner_falls l r]
; prof_falls is the number of falls from professional skaters
; hockey_falls is the number of falls from hockey skaters
; beginner_falls is the number of falls from beginner skaters
; l is the probability of skaters turning left.
; r is the probability of skaters turning right.
turtles-own [skater_satisfaction skater_speed turning_ability nearby_skaters nearest-skater wait_time prof_fallen hockey_fallen beginner_fallen]
; skater_speed would be used to characterize the aggression of the skaters
; turning_ability is how well the skater can turn
; nearest-skater is closest skater to the current skater
; skater_satisfaction is the satisfaction value of the skater.
; nearest_skaters are the nearest skaters within the perception of the skater.
; wait_time is the amount of ticks that the skater will wait before they get back up after falling down.
; prof_fallen is for the number of times that the professional skaters fall (for each professional skater)
; hockey_fallen is for the number of times hockey skaters fall (for each hockey skater)
; beginner_fallen is for the number of times beginner skaters fall (for each beginner skater)
; move turtle in random direction, then if they collide, you would make them turn if able (speed low enough) and then wait then start again.
to setup ;sets up the patch colors of the rink background as well as different settings of the skaters. This setup also establishes a new plot of satisfactions among the three skaters
 clear-all
 setup-patches
 setup-skaters
 set-current-plot "Skater Satisfaction vs. Group"
 reset-ticks
end

to go ;the go function asks the turtles to move and if they're able to turn, which is later explained, and for skaters in the same patch to turn red and temporarily stop and decrease their wait time
;once their wait time reaches 0, it resets to the skater's original wait time and resets the skater's original settings and adds on the number of falls for that type of skater
;after the skaters have fallen, the skaters follow. Also, for each tick, turtles in the same patch would alter their satisfaction by lowering their satisfaction value for 5.
 update-plots
 ask turtles [move-skaters able-to-turn]
 ask turtles with [count turtles in-radius 1 > 1]
  [able-to-turn set color red
    ask turtles with [color = red] [set skater_satisfaction skater_satisfaction - 0.35 set wait_time wait_time - 1 set skater_speed 0
    if wait_time = 0 [set color blue
    if turning_ability = 1 [set wait_time beginner_wait_time set skater_speed 0.2 set beginner_falls beginner_falls + 1 set beginner_fallen beginner_fallen + 1]
    if turning_ability = 2 [set wait_time hockey_wait_time set skater_speed 0.7 set hockey_falls hockey_falls + 1 set hockey_fallen hockey_fallen + 1]
    if turning_ability = 3 [set wait_time professional_wait_time set skater_speed 1.2 set prof_falls prof_falls + 1 set prof_fallen prof_fallen + 1]
    ]]
    follow-skaters
  ]
 ask turtles with [count turtles-here >= 2] [change-satisfaction-skaters]
 tick
end

to setup-patches ; this draws the white ice, the light blue end zones, dark blue center square, and red border.
  ask patches [set pcolor white]
  ask patches with [pycor >= -16 and pycor >= 16][ set pcolor red ]
  ask patches with [pycor <= -16 and pycor <= 16][ set pcolor red ]
  ask patches with [pxcor >= -16 and pxcor >= 16][ set pcolor red ]
  ask patches with [pxcor <= -16 and pxcor <= 16][ set pcolor red ]
  ask patches with [(pycor >= -5  and pycor <= -4 and pxcor >= -5  and pxcor <= 5) or (pycor <= 5  and pycor >= 4 and pxcor >= -5  and pxcor <= 5) or (pxcor >= 4  and pxcor <= 5 and pycor <= 5 and pycor >= -5) or (pycor <= 5 and pycor >= -5 and pxcor <= -4  and pxcor >= -5)] [ set pcolor blue - 2  ]
  ask patches with [(pxcor <= 4 and pxcor >= -4 and pycor >= 10 and pycor <= 16) or (pxcor <= 4 and pxcor >= -4 and pycor >= -16 and pycor <= -10)] [set pcolor blue + 4]
end

to setup-skaters ; this establishes the skaters so their falls are all 0, the probabilities for them turning left is 50 and them turning right is 50. The program creates "Num_Skaters" number of skaters set
;set by the slider. Then, the nearby skaters will be initialized to no turtles and skater speeds will be randomly assigned with turning abilties assigned to specific skater speeds and wait times assigned to specific turning abilities
  set prof_falls 0
  set beginner_falls 0
  set hockey_falls 0
  set l 50
  set r 50
  create-turtles Num_Skaters [
    set beginner_fallen 0
    set prof_fallen 0
    set hockey_fallen 0
    set nearby_skaters no-turtles
    set skater_speed random(3) * 0.5 + 0.2
    set skater_satisfaction 200
    if skater_speed = 0.2 [set turning_ability 1]
    if skater_speed = 0.7 [set turning_ability 3]
    if skater_speed = 1.2 [set turning_ability 2]
    if turning_ability = 1 [set wait_time beginner_wait_time]
    if turning_ability = 2 [set wait_time hockey_wait_time]
    if turning_ability = 3 [set wait_time professional_wait_time]
    set color blue
    set size 1.5
  ]
  ask turtles [setxy random-xcor random-ycor set shape "circle"]
end
to move-skaters ; this will add on 2.5 units of satisfaction to the skaters for each tick that they are moving on the ice. They will move forward at their set skater speed and will follow other skaters.
; the skaters will reverse their direction if they
; when the skaters get within 3 patches of the outer wall, they will randomly either turn left (l) or right (r) depending on the probability of them turning either way at that very moment.
; if the color of the patch the skaters are on are either dark or light blue, then they will spin and idle more as skaters tend to practice in those zones.
; if the skaters are on patches with dark or light blue, then their satisfaction will continue to increase by additional 0.35 (enjoyment from skating on the light blue)
; ultimately, this function would either show the turning abilities of the skaters or their skater speeds if show-turning-ability? is false.
    set skater_satisfaction skater_satisfaction + 2.5
    fd skater_speed
    follow-skaters
    if abs [pxcor] of patch-ahead 2 = max-pxcor or abs [pycor] of patch-ahead 2 = max-pycor [set heading (- heading)]
    if abs [pxcor] of patch-ahead 3 = max-pxcor or abs [pycor] of patch-ahead 3 = max-pycor
    [ifelse random-float(1) <= (l)/(l + r) [set heading heading + 90 set l l + 1 set r r - 1][set heading heading - 90 set r r + 1 set l l - 1]]
    if (pcolor = blue - 2) or (pcolor = blue + 4) [ask turtles with [pcolor = blue - 2 or pcolor = blue + 4] [fd (pi * 6 / 180) * (skater_speed) rt 30 * skater_speed + 1]]
    ask turtles with [pcolor = blue - 2 or pcolor = blue + 4] [set skater_satisfaction skater_satisfaction + 0.35]
    ifelse show-turning-ability? [set label turning_ability][ifelse show-speed? [ set label skater_speed ] [ set label ""]]
end
to able-to-turn ; this function
    if any? turtles-on patch-ahead perception and count turtles-on patch-ahead perception > 0 and nearest-skater != 0 and nearest-skater != nobody [
    ifelse turning_ability = 1 and skater_speed < 0.7 [turn-away ([heading] of (nearest-skater)) max-turn][turn-towards ([heading] of (nearest-skater)) max-turn]
    if turning_ability = 2 [turn-towards ([heading] of (nearest-skater)) max-turn]
    if turning_ability = 3 [turn-away ([heading] of (nearest-skater)) max-turn]
    fd skater_speed
  ]
end
to change-satisfaction-skaters ; change-satisfaction-skaters would decrease skaters' satisfaction in the same patch by 5 satisfaction points.
  ask turtles-here[
      set skater_satisfaction skater_satisfaction - 5
  ]
end
to follow-skaters ; this makes skaters follow each other in flock-like behavior. This would determine if there are any nearby skaters and would determine the closest skater, then if they skaters
; aren't too close, then the skaters will align with and adhere to the group movement. Otherwise, they will try to avoid crowding.
  find-skaters
  if any? nearby_skaters
    [ find-nearest-skater
      ifelse distance nearest-skater < minimum-separation
        [ avoid-crowding ]
        [ group-alignment
          group-adhere ] ]
end
to find-skaters ; This finds the nearby skaters with the skater's perception range.
  set nearby_skaters other turtles in-radius perception
end

to find-nearest-skater ; This finds a random skater in the perception range of the nearby skaters.
  set nearest-skater min-one-of nearby_skaters [distance myself]
end


to avoid-crowding ; avoid-crowding is, as long as the skater has a nearby skater, where skaters would turning away from their closest skater by the maximum amount that they can turn by to avoid crowding.
  if nearest-skater != nobody [turn-away ([heading] of (nearest-skater)) max-turn]
end

to group-alignment ; this allows skaters to turn towards skaters the overall, global, group movement.
  turn-towards average-skater-heading alignment-with-group
end

to-report average-skater-heading ; average-skater-heading reports the degree of the direction of the aggregate direction among all the skaters.
  let x sum [dx] of nearby_skaters with [pcolor != blue - 2 and pcolor != blue + 4]
  let y sum [dy] of nearby_skaters with [pcolor != blue - 2 and pcolor != blue + 4]
  ifelse x = 0 and y = 0
    [ report heading ]
    [ report atan x y ]
end

to group-adhere ; this enables skaters to adhere to group movement or turn towards the average direction of all the skaters.
  turn-towards average-heading-towards-skaters group-adherence
end

to-report average-heading-towards-skaters ; this reports the average direction toward the skaters, which is the tangent of the average of all the headings of x components over average of the headings of y components.
  let x mean [sin (towards myself + 180)] of nearby_skaters
  let y mean [cos (towards myself + 180)] of nearby_skaters
  ifelse x = 0 and y = 0
    [ report heading ]
    [ report atan x y ]
end

to turn-towards [new-heading most-to-turn] ; the function enables skaters to turn towards by the difference between a new direction and their maximum ability to turn.
  turn-at-most (subtract-headings new-heading heading) most-to-turn
end

to turn-away [new-heading most-to-turn] ; the function enables skaters to turn away by the difference between a new direction and a skater's maximum ability to turn.
  turn-at-most (subtract-headings heading new-heading) most-to-turn
end

to turn-at-most [turn most-to-turn] ; the function makes the skater turn at most by the most-to-turn value.
  ifelse abs turn > most-to-turn
    [ ifelse turn > 0
        [ rt most-to-turn ]
        [ lt most-to-turn ] ]
    [ rt turn ]
end

; Copyright 2018 Dylan Chou.
; Professor Miller Freshman Modeling Seminar
; Figure Skating Rink Model
@#$#@#$#@
GRAPHICS-WINDOW
368
10
869
512
-1
-1
14.94
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
3
10
62
43
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
65
10
130
43
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
6
99
124
132
Num_Skaters
Num_Skaters
0
100
20.0
1
1
NIL
HORIZONTAL

PLOT
1
137
345
319
Skater Satisfaction vs. Group
Skater Group
Satisfaction
0.0
3.0
-10.0
10.0
true
true
"" ""
PENS
"beginner skaters" 1.0 0 -2674135 true "" "if count turtles with [turning_ability = 1] != 0 [plot mean[skater_satisfaction] of turtles with [turning_ability = 1]]"
"hockey skaters" 1.0 0 -10899396 true "" "if count turtles with [turning_ability = 2] != 0 [plot mean[skater_satisfaction] of turtles with [turning_ability = 2]]"
"professional skaters" 1.0 0 -13345367 true "" "if count turtles with [turning_ability = 3] != 0 [plot mean[skater_satisfaction] of turtles with [turning_ability = 3]]"

SWITCH
0
322
166
355
show-turning-ability?
show-turning-ability?
0
1
-1000

SWITCH
168
321
346
354
show-speed?
show-speed?
1
1
-1000

SLIDER
136
12
350
45
beginner_wait_time
beginner_wait_time
0
100
75.0
1
1
NIL
HORIZONTAL

SLIDER
136
52
350
85
hockey_wait_time
hockey_wait_time
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
135
94
352
127
professional_wait_time
professional_wait_time
0
100
25.0
1
1
NIL
HORIZONTAL

MONITOR
2
357
123
390
Times Prof, Fallen
mean [prof_fallen] of turtles
17
1
8

MONITOR
119
357
239
390
Times Hoc. Fallen
mean [hockey_fallen] of turtles
17
1
8

MONITOR
226
357
344
390
Times Beg. Fallen
mean [beginner_fallen] of turtles
17
1
8

MONITOR
3
50
130
91
Proportion of Falls
(prof_falls + hockey_falls + beginner_falls) / ticks
17
1
10

SLIDER
226
393
357
426
perception
perception
0
8
1.0
1
1
patches
HORIZONTAL

SLIDER
5
429
223
462
minimum-separation
minimum-separation
0
10
5.7
0.1
1
patches
HORIZONTAL

SLIDER
4
464
222
497
max-turn
max-turn
0
90
37.6
0.1
1
 degrees
HORIZONTAL

SLIDER
4
500
223
533
alignment-with-group
alignment-with-group
0
10
2.3
0.1
1
degrees
HORIZONTAL

SLIDER
3
394
222
427
group-adherence
group-adherence
0
10
8.0
0.1
1
degrees
HORIZONTAL

MONITOR
227
429
356
474
count beginners
count turtles with [turning_ability = 1]
17
1
11

MONITOR
227
476
356
521
count hockeys
count turtles with [turning_ability = 2]
17
1
11

MONITOR
228
526
357
571
count professionals
count turtles with [turning_ability = 3]
17
1
11

@#$#@#$#@
## WHAT IS IT?

This model is a simulation of movements and alleviation, satisfaction from skaters on an ice rink. 

## HOW IT WORKS

The skaters would follow their nearest neighbor, within their perception radius. Thus, when the program runs, the skaters would fall if they collide with one another. They could avoid collision if they have a high enough turning ability with a decent speed. The skaters would spin and idle more within the dark blue square or at the blue end zones within the rink. It's assumed that when skaters leave the screen, it's attributed to random error or from skaters exiting the rink.  

## HOW TO USE IT

SETUP randomly allocates turtles throughout the canvas and assigns each a random turning ability with an associated skater speed. GO runs the program and allows the skaters to interact and fall after hitting each other. Most sliders are self-explanatory in what they do, but group adherence is a measure of how closely the skaters will adhere to group movement in the rink. Minimum separation slider is representative of how close the skaters can be before avoiding crowding. The most to turn is the maximum number of degrees that the skaters can turn. Alignment with group is how well the skater can align with the direction of the group. Perception is the slider that informs the radius, or vision, the skaters can have. 

## THINGS TO TRY

Try out the different sliders and see the effects on the skater satisfactions and the emergent movements within the ice rink model. 

## CREDITS AND REFERENCES

Models Library: Flocking  
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
