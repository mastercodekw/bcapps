#!/bin/perl

require "/usr/local/lib/bclib.pl";
require "$bclib{githome}/MAPS/bc-mapserver-lib.pl";

# TODO: get some of this info from the .hdr and .prj files

# TODO: worry about NODATA

for $i ("climate", "landuse", "popcount", "popdensity", "slope") {

  # most of the data comes from mapMeta...
  $mapmeta{$i} = mapMeta({"filename" => "/mnt/squash/$i.bin"});

  # these are all raster maps
  $mapmeta{$i}->{type} = "raster";

  # TODO: add $extra array (currently maps) from bc-maps.pl

}



# debug(var_dump("MAPMETA", \%mapmeta));

# %{$mapmeta{"landuse"}} =(
#  "filename"=>"/mnt/villa/user/NOBACKUP/EARTHDATA/LANDUSE/landuse.bin",
#  "bits" => 8, "nData" => 90, "sData" => -90, "wData" => -180, "eData" => 180,
#  "lngRes" => 0.002777777777778, "latRes" => 0.002777777777778
# );

# die "TESTING";


# this would come from user

%reqdata =(
 map => "landuse", slat => 70, nlat => 80, wlng => -120, elng => -110,
 dlat => 0.01, dlng => 0.01
);

$data = mapData(\%reqdata);

print $data->{data};

die "TESTING";

=item legend

Legend for cover:

NB_LAB;LCCOwnLabel;R;G;B
0;No data;0;0;0
10;Cropland, rainfed;255;255;100
11;Herbaceous cover;255;255;100
12;Tree or shrub cover;255;255;0
20;Cropland, irrigated or post-flooding;170;240;240
30;Mosaic cropland (>50%) / natural vegetation (tree, shrub, herbaceous cover) (<50%);220;240;100
40;Mosaic natural vegetation (tree, shrub, herbaceous cover) (>50%) / cropland (<50%) ;200;200;100
50;Tree cover, broadleaved, evergreen, closed to open (>15%);0;100;0
60;Tree cover, broadleaved, deciduous, closed to open (>15%);0;160;0
61;Tree cover, broadleaved, deciduous, closed (>40%);0;160;0
62;Tree cover, broadleaved, deciduous, open (15-40%);170;200;0
70;Tree cover, needleleaved, evergreen, closed to open (>15%);0;60;0
71;Tree cover, needleleaved, evergreen, closed (>40%);0;60;0
72;Tree cover, needleleaved, evergreen, open (15-40%);0;80;0
80;Tree cover, needleleaved, deciduous, closed to open (>15%);40;80;0
81;Tree cover, needleleaved, deciduous, closed (>40%);40;80;0
82;Tree cover, needleleaved, deciduous, open (15-40%);40;100;0
90;Tree cover, mixed leaf type (broadleaved and needleleaved);120;130;0
100;Mosaic tree and shrub (>50%) / herbaceous cover (<50%);140;160;0
110;Mosaic herbaceous cover (>50%) / tree and shrub (<50%);190;150;0
120;Shrubland;150;100;0
121;Shrubland evergreen;120;75;0
122;Shrubland deciduous;150;100;0
130;Grassland;255;180;50
140;Lichens and mosses;255;220;210
150;Sparse vegetation (tree, shrub, herbaceous cover) (<15%);255;235;175
151;Sparse tree (<15%);255;200;100
152;Sparse shrub (<15%);255;210;120
153;Sparse herbaceous cover (<15%);255;235;175
160;Tree cover, flooded, fresh or brakish water;0;120;90
170;Tree cover, flooded, saline water;0;150;120
180;Shrub or herbaceous cover, flooded, fresh/saline/brakish water;0;220;130
190;Urban areas;195;20;0
200;Bare areas;255;245;215
201;Consolidated bare areas;220;220;220
202;Unconsolidated bare areas;255;245;215
210;Water bodies;0;70;200
220;Permanent snow and ice;255;255;255

=cut

# testing the landuse.dat file

open(A, "/mnt/villa/user/NOBACKUP/EARTHDATA/LANDUSE/landuse.dat");

debug(var_dump("land", getLandUse(str2hashref("lat=0&lon=0"))));

=item getLandUse(%hash)

Get the land use data for a single lat/lon in hash

TODO: figure out how to handle permanent filehandle like A better

=cut

sub getLandUse {

  my(%hash) = %{$_[0]};
  my($data);

  my($y) = round(($hash{lat}+90)*360);
  my($x) = round(($hash{lon}+180)*360);
  my($byte) = $y*129601 + $x;
  seek(A, $byte, SEEK_SET);
  sysread(A, $data, 1);
  return str2hashref("landuse=".ord($data));
}

