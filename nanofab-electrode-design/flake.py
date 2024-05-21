# Python version:

import pya
import os
import math

##################################################
##################################################
##################################################

# input file paths here
in_path = "/Users/jacquelinewang/Documents/MATLAB/"
txtname = "test.txt"

# output file paths here
out_path = "/Users/jacquelinewang/Desktop"
filename = "flake.gds"

# define drawing layers in KLayout. Edit to use different layers
layout = pya.Layout()
top = layout.create_cell("TOP")
l1 = layout.layer(1, 0)

# define width of route (um)
route_wid = 30
# define the length and width of the small pads at the very end of the routes
end_electrode_len = 100
end_electrode_wid = 100

##################################################
##################################################
##################################################


###################
# Routing Helpers #
###################

def distance(point1, point2):
    return math.sqrt((point1[0]-point2[0])**2 + (point1[1]-point2[1])**2)

pads_centers = [[-2750, 500], [-3500, 2200], [-2500, 3500], [-500, 3500], [500, 3500],
    [2500, 3500], [3500, 2200], [2750, 500], [2750, -500], [3500, -2200], [2500, -3500],
    [500, -3500], [-500, -3500], [-2500, -3500], [-3500, -2200], [-2750, -500]]
pad_size = 500


def route_from_special(coord, pad, mode):
    """
    routes from special coordinates (of form 200x, 200y)
    """
    x, y = coord[0], coord[1]
    new_x = min([math.floor(pad[0]/200)*200, math.ceil(pad[0]/200)*200], key = lambda a: abs(a-x))
    new_y = min([math.floor(pad[1]/200)*200, math.ceil(pad[1]/200)*200], key = lambda a: abs(a-y))
    if mode == "xy": # moves in x coordinate first, then y
        return [coord,(new_x, y), (new_x, new_y)]
    elif mode == "yx":
        return [coord,(x, new_y), (new_x, new_y)]
    elif mode == "xyx":
        temp = min(pad[0]+300, pad[0]-300, key = lambda a: abs(a-x))
        return [coord, (temp, y), (temp, new_y), (new_x, new_y)]
    elif mode == "yxy":
        temp = min(pad[1]+300, pad[1]-300, key = lambda a: abs(a-y))
        return [coord, (x, temp), (new_x, temp), (new_x, new_y)]

def get_mode(coord, special, pad, x_or_y):
    """
    determines which mode should we route in based on the coordinates of start point,
    even hundred multiple special coordinate, and pad coordinate

    x_or_y param (str, either "x" or "y") determines whether we need to be
    comparing the x values of coordinates or y values,
    this is determined in the routing main body code based on the relative
    location of the pair of pads (y for up-down pairs).
    """
    mapping = {"x": 0, "y": 1, 0: "x", 1 : "y"} # helps with simplifying, since
    char, ind = x_or_y, mapping[x_or_y] # the judgement is symmetric whether x_or_y is x or y
    other_ind, other_char = (ind + 1)%2, mapping[(ind + 1)%2]
    if (special[ind] > coord[ind] and special[ind] > pad[ind]
            or special[ind] < coord[ind] and special[ind] < pad[ind]):
        return other_char + char + other_char
    return char + other_char


def get_closest_pad(special):
    """
    return a pad index and pad coord given a special coordinate
    """
    return min(enumerate(pads_centers), key = lambda lst: distance(lst[1], special))

def route(coords, nanostructure):
    """
    route a pair of coordinates.
    coords: the two routing start points, in tuple form (or lists work too)
    nanostructure: list of tuples (or lists)
    outputs: 2 lists of tuples of route start, turning, and end points
    """
    # imagine placing a box around the flake and getting the corners of the box
    x_min, x_max = min(nanostructure, key = lambda pair: pair[0])[0], max(nanostructure, key = lambda pair: pair[0])[0]
    y_min, y_max = min(nanostructure, key = lambda pair: pair[1])[1], max(nanostructure, key = lambda pair: pair[1])[1]
    coord1, coord2 = coords[0], coords[1] # the two starting points
    pad_ind, pad = get_closest_pad(coord1) # get a closest pad. route to pair of pads
    # determine the other pad
    if pad_ind % 2 == 0:
        if pad_ind in [0, 14, 2, 4]:
            pad1, pad2 = pad, pads_centers[pad_ind+1]
        else:
            pad1, pad2 = pads_centers[pad_ind+1], pad
    elif pad_ind in [1, 15, 3, 5]:
        pad1, pad2 = pads_centers[pad_ind-1], pad
    else:
        pad1, pad2 = pad, pads_centers[pad_ind-1]
    # determine special coordinates and routing modes
    if pad_ind in [0, 1, 6, 7, 8, 9, 14, 15]: # pads are up-down pair
        if coord1[1] > coord2[1]:
            coord1, coord2 = coord2, coord1 # make lower one coord1
        special1, special2 = (min([math.floor(coord1[0]/200)*200, math.ceil(coord1[0]/200)*200],
                            key = lambda val: abs(val-pad1[0])), math.floor(y_min/200) * 200), (min(
                                [math.floor(coord2[0]/200)*200, math.ceil(coord2[0]/200)*200],
                            key = lambda val: abs(val-pad2[0])), math.ceil(y_max/200) * 200)
                            #find "special coordinate" closest to the corner of box
        mode1, mode2 = get_mode(coord1, special1, pad1, "y"), get_mode(coord2, special2, pad2, "y")
    else: # pads are left-right pair
        mode = "xy"
        if special1[0] > special2[0]:
            coord1, coord2 = coord2, coord1 # make left one coord1
            special1, special2 = (math.floor(x_min/200) * 200, min([math.floor(coord1[1]/200)*200, math.ceil(coord1[1]/200)*200],
                          key = lambda val: abs(val-pad1[1]))),(math.ceil(x_max/200) * 200, min(
                              [math.floor(coord2[1]/200)*200, math.ceil(coord2[1]/200)*200],
                          key = lambda val: abs(val-pad2[1])))
                        #find "special coordinate" closest to the corner of box
        mode1, mode2 = get_mode(coord1, special1, pad1, "x"), get_mode(coord2, special2, pad2, "x")
    # route pair. special1 and pad1 are left/down
    return ([coord1] + route_from_special(special1, pad1, mode1),
                [coord2] + route_from_special(special2, pad2, mode2))

######################
# reading input file #
######################

def read_file(path, name):
    """
    read provided input file. output list of strings: ["nanostructure", "two floats", "two floats", ...]
    tailored to matlab file output format.
    also needs to be changed if Matlab file output format changes.
    """
    f = open(os.path.join(path, name))
    lines = [line.strip("\n") for line in f]
    f.close()
    return lines

def to_coords(lines):
    """
    given lines outputted by read_file, returns list of lists,
    each smaller list consists of tuples of coordinates for a certain object
    tailored to matlab file output format.
    also needs to be changed if Matlab file output format changes.

    in helper, i+2 is because we are assuming that
    an empty line is followed by a string ("nanostructure" "electrodes") which we skip.
    this can be changed to actually consider the information given by those strings
    """
    def helper(start):
        coords = []
        for i in range (start, len(lines)):
            if not lines[i]:
                return coords, i+2
            coords.append(tuple(float(num)
                                for num in lines[i].strip("\n").split(",")))
        return coords, i+2
    all_coords = []
    coords, new_start = helper(1)
    while new_start < len(lines):
        all_coords.append(coords)
        coords, new_start = helper(new_start)
    all_coords.append(coords)
    return all_coords

def electrode_center(electrode):
    """
    gets the center of an electrode (rectangular shape)
    """
    return (electrode[0][0]+electrode[2][0])/2, (electrode[0][1]+electrode[2][1])/2

######################
#add shapes to layer #
######################
def add_shapes():
    """
    Puts all the helpers together. Modifies layout layer and returns nothing.

    1. Turn nanostructure and electrodes into Klayout polygons and add to layer
    2. Turn routes into Klayout paths and add to layer

    Assumes that in the matlab file, a nanostructure is always followed by 2 electrodes.
    If this is not the case, edit the mod arithmetic part (or to_coords function)
    """
    all_coords = to_coords(read_file(in_path, txtname))
    for ind, polygon in enumerate(all_coords):
        top.shapes(l1).insert(pya.DPolygon([pya.DPoint(*p) for p in polygon]))
        if ind%3 == 0: # put nanostructure information into parameters needed for routing
            routing_inputs = [polygon]
        elif ind%3 == 1: # first electrode- routing start points
            routing_inputs.append(electrode_center(polygon))
        else: # second electrode- enough info to start routing
            path1, path2 = route([routing_inputs[1], electrode_center(polygon)], routing_inputs[0])
            for path in [path1, path2]:
                top.shapes(l1).insert(pya.DPath([pya.DPoint(*point) for point in path], route_wid))
                # add the end electrode
                end_electrode = [(path[-1][0] + x, path[-1][1] + y) for x in [end_electrode_len/2, -end_electrode_len/2] for y in [end_electrode_wid, -end_electrode_wid/2]]
                # swap last two coordinates because corner point order matters for DPolygon
                end_electrode[2], end_electrode[3] = end_electrode[3], end_electrode[2]
                top.shapes(l1).insert(pya.DPolygon([pya.DPoint(*p) for p in end_electrode]))
##############
# write file #
##############
add_shapes()
layout.write(os.path.join(out_path, filename))
