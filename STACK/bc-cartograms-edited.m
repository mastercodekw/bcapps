<formulas>

usa = Import["/home/barrycarter/BCGIT/STACK/us_states.kml", "Data"];

popdata = Import[
"/home/barrycarter/BCGIT/STACK/CenPop2010_Mean_ST.txt", "CSV"][[2 ;;, 2 ;; 3]];

popdata = Thread[popdata[[All, 1]] -> popdata[[All, 2]]];

states = Entity["Country","UnitedStates"]["AdministrativeDivisions"];

stateabbrev = Table[i["Name"] -> i["StateAbbreviation"], {i, states}];

presresults =  Import["/home/barrycarter/BCGIT/STACK/tables2008.xls"];

electoralVotes = 
  Thread[presresults[[3, 5 ;; 55, 1]] -> 
     Total /@ (presresults[[3, 5 ;; 55, {2, 3}]] /. "" -> 0)] /. 
   stateabbrev;

presresults = presresults[[3, 5 ;; 55, {1, 4, 5}]] /. stateabbrev;

transform[s_] := StringTrim[s, Whitespace ~~ "(" ~~ ___ ~~ ")"]

polygons = 
  Thread[transform[
     "PlacemarkNames" /. usa[[1]]] -> ("Geometry" /. usa[[1]])];

(* more GeoPosition ugliness *)

polygons = polygons /. GeoPosition[x_] -> x

stateNames = polygons[[All, 1]];

stateNames = 
  Extract[stateNames, 
   Position[stateNames, x_ /; x != "Alaska" && x != "Hawaii"]];

stateColors = 
  Flatten[{#[[1]] -> If[#[[2]] > #[[3]], Blue, Red]} & /@ 
    presresults];

area[pts_] := 
  Plus @@ (ListCorrelate[{1, 1}, First /@ pts, 
       1] ListCorrelate[{-1, 1}, Last /@ pts, 1])/2;

(* redefining area correctly here *)

area[pts_] := Area[Polygon[pts]];

com[pts_] := Module[{moments, thearea},
   moments = (1/6) {
      Plus @@ ((#1^2 + #1 #2 + #2^2 & @@ ({RotateLeft[#], #} &@(First 
/@ pts))) ListCorrelate[{-1, 1}, Last /@ pts, 1]),
      -Plus @@ ((#1^2 + #1 #2 + #2^2 & @@ ({RotateLeft[#], #} &@(Last 
/@ pts))) ListCorrelate[{-1, 1}, First /@ pts, 1]) };
   thearea = area[pts];
   Return@If[thearea == 0.0, Mean[pts], moments/thearea]];

com2[pts_, weights_] := Module[{},
   Return[Total[weights*pts]/Total[weights]]]; 

origdata = (stateNames /. polygons)[[All, 2 ;;, 1]];

(* this ugliness to get rid of GeoPosition header *)

origdata = origdata /. GeoPosition[x_] -> x

newdata = origdata;

nits = 10;

nstates = Length@stateNames;

weights = (stateNames /. popdata)/Total[stateNames /. popdata];

</formulas>

For[j = 1, j <= nits*nstates(*Length@origdata*),
  i = Mod[j - 1, nstates] + 1;
  tempdata = newdata;
  (*compts=Map[com,newdata,{2}];*)

  polyarrs = Map[area, newdata, {2}];

  statearrs = Total /@ polyarrs;
  allarr = Total@statearrs;
  comall = 
   Table[com2[com /@ newdata[[i]], polyarrs[[i]]], {i, 
     Length@origdata}];
  norms = Map[Norm[(# - comall[[i]])] &, tempdata, {3}];
  exp = Tanh[Log[1/weights[[i]] statearrs[[i]]/allarr]]/2;
  newdata = 
   Map[(# - comall[[i]]) &, 
     tempdata, {3}] (1 - exp Exp[-(norms/Max[norms[[i]]])^2]);
  newdata *= Sqrt[
   Total[Total /@ Map[area, tempdata, {2}]]/
    Total[Total /@ Map[area, newdata, {2}]]];
  j++];


plotcolors = stateNames /. stateColors;

(* corrected by BC *)

plotcolors = stateNames /. stateColors;


Show[Graphics[
  Table[{EdgeForm[Directive[Black, AbsoluteThickness[0.5]]], 
    plotcolors[[i]], Polygon[newdata[[i]]]}, {i, Length@newdata}]], 
 AspectRatio -> Automatic]

(* below here is testing *)

Table[Area[Polygon[i]], {i, origdata}]
