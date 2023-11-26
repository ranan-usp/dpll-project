
# Enter your Python code here

import math
from pya import *
import numpy as n
class OriginalError(Exception):
    pass

def create_Box(cell,index,pos1,pos2):
    
    cell.shapes(index).insert(Box.new(pos1[0],pos1[1],pos2[0],pos2[1]))

# text
def create_Text(cell,index,string,pos):
    DBU = 1000
    width = 5
    width *= DBU
    create_Box(cell,index,[pos[0]-width//2,pos[1]-width//2],[pos[0]+width//2,pos[1]+width//2])
    cell.shapes(index).insert(Text.new(string,pos[0],pos[1]))


if __name__ == '__main__':

    app = Application.instance()
    mw = app.main_window()

    # layoutのcurrent_viewを取得
    try:
        lv = mw.current_view()
        if lv is None:
            raise OriginalError('Cancelled')
    except OriginalError as e:
        print(e)

    # cellの取得
    cell = lv.active_cellview().cell

    # layoutの取得
    LAYOUT = cell.layout()
    
    DBU = 1 / cell.layout().dbu

    bsize = 1.0
    
    ################################################
    # 各layerのindexを取得
    m_index = LAYOUT.layer(LayerInfo.new(81,0))
    m_index = LAYOUT.layer(LayerInfo.new(46,0))
    m2_index = LAYOUT.layer(LayerInfo.new(42,5))
    m3_index = LAYOUT.layer(LayerInfo.new(36,5))
    m4_index = LAYOUT.layer(LayerInfo.new(46,5))
    label_index = LAYOUT.layer(LayerInfo.new(81,10))
    ################################################

    key = 0
    w = 0.6
    wd = w*DBU

    cir_size = [2,1]

    length = 50
    a_move = 0.225

    offset_y = 342.2

    w = 0.6
    DBU = 1000  # データベースユニット(DBU)、例えば1000
    wd = w * DBU

    offset_y = 342.2
    offset_x = -150  # Jの文字の開始位置を調整
    offset = [offset_x, offset_y]

    offset[0] += 300
    create_Box(cell,m2_index,[(offset[0]-300/2)* DBU,0],[(offset[0]+300/2)* DBU,352.2*DBU])
    create_Box(cell,m3_index,[(offset[0]-300/2)* DBU,0],[(offset[0]+300/2)* DBU,352.2*DBU])
    # create_Box(cell,m4_index,[(offset[0]-300/2)* DBU,0],[(offset[0]+300/2)* DBU,352.2*DBU])
   
    # A
    for x in range(550):

        y_position = offset[1] - x*w

        y_position = round(y_position,1)

        # right
        lcenter_position = [offset[0] + x*a_move ,y_position]
        
        points = [[lcenter_position[0]-length//2,lcenter_position[1]],[lcenter_position[0]+length//2,lcenter_position[1]]]
        points=n.array(points)*DBU

        if x == 0:
            create_Text(cell,label_index,'vdd',points[0])
        points = [[round(points[0][0],-2),round(points[0][1],-2)],[round(points[1][0],-2),round(points[1][1],-2)]]
        a1 = []
        for p in points:
            a1.append(Point.new(int(p[0]), int(p[1])))
        cell.shapes(m_index).insert(Path.new(a1,wd+0.2*DBU))

        # left
        rcenter_position = [offset[0] - x*a_move ,y_position]
        points = [[rcenter_position[0]-length//2,rcenter_position[1]],[rcenter_position[0]+length//2,rcenter_position[1]]]
        points=n.array(points)*DBU
        points = [[round(points[0][0],-2),round(points[0][1],-2)],[round(points[1][0],-2),round(points[1][1],-2)]]
        a1 = []
        for p in points:
            a1.append(Point.new(int(p[0]), int(p[1])))
        cell.shapes(m_index).insert(Path.new(a1,wd+0.2*DBU))

        # middle

        if -20 + (offset[1]-200) < y_position < 20 + (offset[1]-200):
            points = [lcenter_position,rcenter_position]
            points=n.array(points)*DBU
            points = [[round(points[0][0],-2),round(points[0][1],-2)],[round(points[1][0],-2),round(points[1][1],-2)]]
            a1 = []
            for p in points:
                a1.append(Point.new(int(p[0]), int(p[1])))
            cell.shapes(m_index).insert(Path.new(a1,wd+0.2*DBU))

    offset[0] += 300
    create_Box(cell,m2_index,[(offset[0]-300/2)* DBU,0],[(offset[0]+300/2)* DBU,352.2*DBU])
    create_Box(cell,m3_index,[(offset[0]-300/2)* DBU,0],[(offset[0]+300/2)* DBU,352.2*DBU])
    # create_Box(cell,m4_index,[(offset[0]-300/2)* DBU,0],[(offset[0]+300/2)* DBU,352.2*DBU])

    # N
    for x in range(550):

        y_position = offset[1] - x*w

        y_position = round(y_position,1)

        # right
        lcenter_position = [offset[0] - 110 , y_position]
        points = [[lcenter_position[0]-length//2,lcenter_position[1]],[lcenter_position[0]+length//2,lcenter_position[1]]]
        
        points=n.array(points)*DBU
        points = [[round(points[0][0],-2),round(points[0][1],-2)],[round(points[1][0],-2),round(points[1][1],-2)]]
        if x == 0:
            create_Text(cell,label_index,'vss',points[0])
        a1 = []
        for p in points:
            a1.append(Point.new(int(p[0]), int(p[1])))
        cell.shapes(m_index).insert(Path.new(a1,wd+0.2*DBU))

        # left
        rcenter_position = [offset[0] + 110,y_position]
        points = [[rcenter_position[0]-length//2,rcenter_position[1]],[rcenter_position[0]+length//2,rcenter_position[1]]]
        points=n.array(points)*DBU
        points = [[round(points[0][0],-2),round(points[0][1],-2)],[round(points[1][0],-2),round(points[1][1],-2)]]
        a1 = []
        for p in points:
            a1.append(Point.new(int(p[0]), int(p[1])))
        cell.shapes(m_index).insert(Path.new(a1,wd+0.2*DBU))

        # middle
        mcenter_position = [offset[0] - 110 + x*0.4 , y_position]
        points = [[mcenter_position[0]-length//2,mcenter_position[1]],[mcenter_position[0]+length//2,mcenter_position[1]]]
        points=n.array(points)*DBU
        points = [[round(points[0][0],-2),round(points[0][1],-2)],[round(points[1][0],-2),round(points[1][1],-2)]]
        a1 = []
        for p in points:
            a1.append(Point.new(int(p[0]), int(p[1])))
        cell.shapes(m_index).insert(Path.new(a1,wd+0.2*DBU))   

    offset[0] += 300
    create_Box(cell,m2_index,[(offset[0]-300/2)* DBU,0],[(offset[0]+300/2)* DBU,352.2*DBU])
    create_Box(cell,m3_index,[(offset[0]-300/2)* DBU,0],[(offset[0]+300/2)* DBU,352.2*DBU])
    # create_Box(cell,m4_index,[(offset[0]-300/2)* DBU,0],[(offset[0]+300/2)* DBU,352.2*DBU])

    # A
    for x in range(550):

        y_position = offset[1] - x*w

        y_position = round(y_position,1)

        # right
        lcenter_position = [offset[0] + x*a_move ,y_position]
        points = [[lcenter_position[0]-length//2,lcenter_position[1]],[lcenter_position[0]+length//2,lcenter_position[1]]]
        points=n.array(points)*DBU
        points = [[round(points[0][0],-2),round(points[0][1],-2)],[round(points[1][0],-2),round(points[1][1],-2)]]
        a1 = []
        for p in points:
            a1.append(Point.new(int(p[0]), int(p[1])))
        cell.shapes(m_index).insert(Path.new(a1,wd+0.2*DBU))

        # left
        rcenter_position = [offset[0] - x*a_move ,y_position]
        points = [[rcenter_position[0]-length//2,rcenter_position[1]],[rcenter_position[0]+length//2,rcenter_position[1]]]
        points=n.array(points)*DBU
        points = [[round(points[0][0],-2),round(points[0][1],-2)],[round(points[1][0],-2),round(points[1][1],-2)]]
        a1 = []
        for p in points:
            a1.append(Point.new(int(p[0]), int(p[1])))
        cell.shapes(m_index).insert(Path.new(a1,wd+0.2*DBU))

        # middle

        if -20 + (offset[1]-200) < y_position < 20 + (offset[1]-200):
            points = [lcenter_position,rcenter_position]
            points=n.array(points)*DBU
            points = [[round(points[0][0],-2),round(points[0][1],-2)],[round(points[1][0],-2),round(points[1][1],-2)]]
            a1 = []
            for p in points:
                a1.append(Point.new(int(p[0]), int(p[1])))
            cell.shapes(m_index).insert(Path.new(a1,wd+0.2*DBU))

    offset[0] += 300
    create_Box(cell,m2_index,[(offset[0]-300/2)* DBU,0],[(offset[0]+300/2)* DBU,352.2*DBU])
    create_Box(cell,m3_index,[(offset[0]-300/2)* DBU,0],[(offset[0]+300/2)* DBU,352.2*DBU])
    # create_Box(cell,m4_index,[(offset[0]-300/2)* DBU,0],[(offset[0]+300/2)* DBU,352.2*DBU])

    # N
    for x in range(550):

        y_position = offset[1] - x*w

        y_position = round(y_position,1)

        # right
        lcenter_position = [offset[0] - 110 , y_position]
        points = [[lcenter_position[0]-length//2,lcenter_position[1]],[lcenter_position[0]+length//2,lcenter_position[1]]]
        
        points=n.array(points)*DBU
        points = [[round(points[0][0],-2),round(points[0][1],-2)],[round(points[1][0],-2),round(points[1][1],-2)]]
        a1 = []
        for p in points:
            a1.append(Point.new(int(p[0]), int(p[1])))
        cell.shapes(m_index).insert(Path.new(a1,wd+0.2*DBU))

        # left
        rcenter_position = [offset[0] + 110,y_position]
        points = [[rcenter_position[0]-length//2,rcenter_position[1]],[rcenter_position[0]+length//2,rcenter_position[1]]]
        points=n.array(points)*DBU
        points = [[round(points[0][0],-2),round(points[0][1],-2)],[round(points[1][0],-2),round(points[1][1],-2)]]
        a1 = []
        for p in points:
            a1.append(Point.new(int(p[0]), int(p[1])))
        cell.shapes(m_index).insert(Path.new(a1,wd+0.2*DBU))

        # middle
        mcenter_position = [offset[0] - 110 + x*0.4 , y_position]
        points = [[mcenter_position[0]-length//2,mcenter_position[1]],[mcenter_position[0]+length//2,mcenter_position[1]]]
        points=n.array(points)*DBU
        points = [[round(points[0][0],-2),round(points[0][1],-2)],[round(points[1][0],-2),round(points[1][1],-2)]]
        a1 = []
        for p in points:
            a1.append(Point.new(int(p[0]), int(p[1])))
        cell.shapes(m_index).insert(Path.new(a1,wd+0.2*DBU))   

