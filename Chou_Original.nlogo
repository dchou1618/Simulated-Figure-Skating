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
    set skater_satisfaction skater_satisfaction + 2.5
    fd skater_speed
    follow-skaters
    if abs [pxcor] of patch-ahead 2 = max-pxcor or abs [pycor] of patch-ahead 2 = max-pycor [set heading (- heading)]
    if abs [pxcor] of patch-ahead 3 = max-pxcor or abs [pycor] of patch-ahead 3 = max-pycor
    [ifelse random-float(1) <= (l)/(l + r) [set heading heading + 90 set l l + 1 set r r - 1][set heading heading - 90 set r r + 1 set l l - 1]]
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
