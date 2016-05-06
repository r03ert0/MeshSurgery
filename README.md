# MeshSurgery

MeshSurgery is the interactive application that we use for viewing and editing 3D  brain meshes.
It combines aspects of a 3D sculpting application such as Blender with
those of a mesh processing application such as MeshLab. But the tool that
is the most useful for neuroanatomy -- MeshSurgery's raison d'être -- is its *Smooth* slider:
The *Smooth* slider lets you navigate from the original geometry of a mesh, to a heavily
smoothed version, and back. This facilitates finding and correcting topological defects.

MeshSurgery is coded in Objective-C and compiled for MacOS.

## Viewing tools
* OpenGL-based interactive 3D viewer.
* Outside and inside are displayed in grey and pink, to facilitate detecting inverted triangles.
* Rotation controlled by a virtual trackball.
* Zoom in and out with the Zoom slider, mouse scroll or the two-finger up/down gesture in track pads.
* Standard views and fixed rotations about the X, Y and Z axes controlled by buttons.
* Non-destructive Crop slider, to easily inspect the inside of a mesh.
* Display vertices, wireframe, face normals
* Show topological defects: non-manifold vertices, edges and faces.
* Display total number of vertices and triangles, euler's characteristic and number of selected vertices.

## Editing tools
* Possibility of creating meshes from scratch: add vertices, edges and faces.
* Select a vertex or a triangle by index
* Flip the normal of selected faces.
* Select the largest connected component.
* Increase or decrease the size of a selection.
* Fill a hole without adding new vertices
* Fill a hole adding a new vertex
* Flip an edge
* Split a non-manifold edge
* Select a non-manifold edge loop given a selected vertex.




