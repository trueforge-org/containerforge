import cadquery as cq
from cq_server.ui import show_object

# UNVERIFIED: show_object signature for cadquery-server 0.4.1
result = cq.Workplane("XY").box(10, 20, 5)
show_object(result)
