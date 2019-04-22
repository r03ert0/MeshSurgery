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

## Keyboard commands
* alt click to select a vertex, and shift alt click will extend the selection  
* select 3 vertices and hit F to create a face; or flip the normal of selected faces
* select 3 vertices and shift backspace will delete the face
* ctrl click will add a vertex at your mouse position; selecting two vertices and then ctrl click will add new vertex in the average z plane of the two vertices
* backspace will delete a selected vertex
* keep alt pressed to move a selected vertex
* select one vertex and push C to center this vertex in the viewer

<img width="1057" alt="ms-1" src="https://cloud.githubusercontent.com/assets/2310732/15064949/7f60b920-135a-11e6-9a09-1d982ef72983.png">
<img width="1057" alt="ms-2" src="https://cloud.githubusercontent.com/assets/2310732/15064950/7f60ea9e-135a-11e6-9021-7d68920073da.png">
<img width="1057" alt="ms-3" src="https://cloud.githubusercontent.com/assets/2310732/15064951/7f5fa95e-135a-11e6-8382-7977194b9176.png">
<img width="1057" alt="ms-4" src="https://cloud.githubusercontent.com/assets/2310732/15064947/7f5f29ca-135a-11e6-8b29-4b29763661fe.png">
<img width="1057" alt="ms-5" src="https://cloud.githubusercontent.com/assets/2310732/15064948/7f5fe1d0-135a-11e6-8fff-575586db8e33.png">
<img width="1057" alt="ms-6" src="https://cloud.githubusercontent.com/assets/2310732/15064952/7f62aece-135a-11e6-9094-2d1854cb95c3.png">
