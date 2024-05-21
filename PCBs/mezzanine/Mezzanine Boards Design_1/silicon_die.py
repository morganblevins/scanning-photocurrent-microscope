#!/usr/bin/env python

# KicadModTree is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# KicadModTree is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with kicad-footprint-generator. If not, see < http://www.gnu.org/licenses/ >.
#
# (C) 2016 by Thomas Pointhuber, <thomas.pointhuber@gmx.at>

import sys
import os

sys.path.append(os.path.join(sys.path[0], "../.."))  # enable package import from parent directory

from KicadModTree import *  # NOQA
#all units in mm
#footprint center default 0,0
board_width = 22
die_size = 10 #size of silicon die (fixed)
pad_width = 1
pad_len = 1.5
distance = 2 #distance from silicon die edge
pads_per_side = 4 #number of pads along each edge
min_separation = 0 #minimum separation between pads
separation = (die_size - pads_per_side*pad_width)/(pads_per_side - 1) #separation between pads

min_via_separation = 0.5
num_via_side = 5 # number of via on each side of square arry
hole_rad = 0.5 #hole diameter for prototyping
via_separation = (die_size - 2*hole_rad*num_via_side)/(num_via_side + 1)

#the following are temporary for testing trace separation
trace_width = 0.25
#consider trace above the rows of pads. the case is symmetrical for the bottom
trace_num1 = 6 #if we route all on front
trace_num2 = 4 #if we route 2 on back
trace_sep1 = (board_width - die_size - pad_len - distance)/(trace_num1 + 1)
trace_sep2 = (board_width - die_size - pad_len - distance)/(trace_num2 + 1)
# print("all front:", trace_sep1)
# print("4 front 2 back:", trace_sep2)

def rect_pad(center, width, length):
    """
    center: LIST of x, y locations (float)
    width, length: FLOAT
    """
    center_x, center_y = center[0], center[1]
    return Polygon(nodes=[[center_x - width/2, center_y - length/2],
                              [center_x - width/2, center_y + length/2],
                              [center_x + width/2, center_y + length/2],
                              [center_x + width/2, center_y - length/2]],
                             layer='F.Cu')

def generate_centers(pad_width, pad_len, pads_per_side):
    """
    return: LIST of LISTS. Each small list is a CENTER list with 2 floats x, y.
    First half of list are row (vertical rects), the second half are columns (horizontal rects)
    """
    assert separation >= min_separation
    xy_list = [-die_size/2 + pad_width/2 + (pad_width+separation)*i
                for i in range(0, pads_per_side)]
    centers = ([[x, die_size/2 + distance + pad_len/2] for x in xy_list] # top row
                + [[x, -die_size/2 - distance - pad_len/2] for x in xy_list] #bottom
                + [[die_size/2 + distance + pad_len/2, y] for y in xy_list] #right
                +[[-die_size/2 - distance - pad_len/2, y] for y in xy_list] #right
                  )
    return centers

def via_centers(num, rad):
    assert via_separation >= min_via_separation
    temp = rad*2+via_separation
    start = - (num//2)*(temp)
    centers = [
        [start + x * temp, start + y * temp] for x in range(num) for y in range(num)
    ]
    return centers

def circ_via(center, rad, numbering):
    return Pad(number=numbering, type=Pad.TYPE_THT, shape=Pad.SHAPE_CIRCLE,
                         at=center, size=rad, drill=rad, layers=Pad.LAYERS_THT)

if __name__ == '__main__':
    footprint_name = "Silicon_die_pad"

    # init kicad footprint
    kicad_mod = Footprint(footprint_name)
    kicad_mod.setDescription("silicon_die_pad")
    kicad_mod.setTags("silicon_die_pad")

    # set general values
    kicad_mod.append(Text(type='reference', text='REF**', at=[0, -3], layer='F.SilkS'))
    kicad_mod.append(Text(type='value', text=footprint_name, at=[1.5, 3], layer='F.Fab'))




    # epad = Polygon(nodes=[[-die_size/2, -die_size/2],
    #                       [-die_size/2, die_size/2],
    #                       [die_size/2, die_size/2],
    #                       [die_size/2, -die_size/2]],
    #                          layer='F.Cu')
    # kicad_mod.append(epad)

    # epad
    kicad_mod.append(ExposedPad(number = 17, at = Vector2D(0, 0),
                                size = 10, via_layout = 5, via_drill = hole_rad,
                        bottom_pad_Layers = ["B.Cu"]))

    #vias in epad
    # for i, center in enumerate(via_centers(num_via_side, hole_rad)):
    #     kicad_mod.append(circ_via(center, hole_rad, i+1))

    #small pads
    centers = generate_centers(pad_width, pad_len, pads_per_side)
    for i, center in enumerate(centers[: 2*pads_per_side]):
        kicad_mod.append(ExposedPad(number = [14, 13, 12, 11, 3, 4, 5, 6][i], at = Vector2D(center),
                                    size = Vector2D(pad_width, pad_len)))
        # kicad_mod.append(rect_pad(center, pad_width, pad_len))
    for j, center in enumerate(centers[2*pads_per_side :]):
        kicad_mod.append(ExposedPad(number = [7, 8, 9, 10, 2, 1, 16, 15][j], at = Vector2D(center),
                                    size = Vector2D(pad_len, pad_width)))
        # kicad_mod.append(rect_pad(center, pad_len, pad_width))

    # create vias
    # kicad_mod.append(Pad(number=1, type=Pad.TYPE_THT, shape=Pad.SHAPE_RECT,
                        #  at=[0, 0], size=[2, 2], drill=1.2, layers=Pad.LAYERS_THT))

    # print render tree
    print(kicad_mod.getCompleteRenderTree())

    # write file
    file_handler = KicadFileHandler(kicad_mod)
    file_handler.writeFile('new_silicon_die_footprint_new.kicad_mod')
