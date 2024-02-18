# Aira - AI Generated AR Tutorials

**Aira is an iOS app that generates AR tutorials using 3D stable diffusion in real time.**

**Devpost: https://devpost.com/software/aira-9sqo1j**

## Inspiration
Not all products are designed in a user-friendly and intuitive way. We often come across devices that are annoying and unclear to use. This is especially true for people with less exposure to tech, such as seniors. Whether it’s setting up a new tech gadget or controlling the AC in a new rental car, reading long user manuals or finding a random YouTube tutorial is currently the best course of action. But what if an AI could generate the tutorial specifically for you directly on your phone and visually explain the product using interactive AR?

## Images:
<img src="https://github.com/nkoorty/TreeHacks/assets/22000925/9ed1517c-bcb5-4851-b9b8-5bdf9692c9bc" alt="thumbnail" style="float: left; margin-right: 10px;"/>
<img src="https://github.com/nkoorty/TreeHacks/assets/22000925/b6e28448-38e8-4a19-a505-12ea95ab0e92" alt="Demo" style="float: left; margin-right: 10px;"/>
<img src="https://github.com/nkoorty/TreeHacks/assets/22000925/1bef3f15-d61d-41bc-84ce-0f9470635c5e" alt="Turtle" style="float: left; margin-right: 10px;" />
<img src="https://github.com/nkoorty/TreeHacks/assets/22000925/0c4e885b-a120-4191-a8d4-b3b4d643ceb2" style="width: 75%; height: 50%;" alt="camera tutorial">




## Workflow
1. User wants to know how to interact with an object.
2. They open the app and place their camera in-front of the object.
3. The user asks their question e.g. How do I do 'X'?
4. Object detection model detects the item in-front of user.
5. Speech to text understands the user’s question and sends the label and prompt to the backend LLM instruction agent.
6. The instruction agent takes the user's prompt and generates a list of clear instructions to resolve the user’s problem.
7. The detected object and contextualised instructions are fed into a 3D stable diffusion model which generates a digital twin that is displayed alongside the real object in AR.
8. The 3D models are positioned in AR space as a visual guidance for the written instructions, which are also shown to the user.

## How we built it

**FrontEnd:**
The core frontend was developed using Swift UI, using ARKit for rendering the tutorials in space and CoreML as the on-device model to detect the object in front of the camera. We also used AVFoundation to enable speech-to-text capabilities to simplify the user experience. For more complex and involved tutorials we aim to make the frontend compatible with the Apple Vision Pro in the near future.

**Instruction Agent:**
The instruction agent simplifies user guidance by generating concise instructions in three clear steps. It receives prompts via a REST API from the front-end, incorporating them into the output JSON format. These instructions are then contextualised for the Text-to-3D model, which facilitates the generation and positioning of AR objects. This process involves passing the question and label through a LLM to produce the finalised JSON.

**Text to 3D Stable Diffusion:**
The text to 3D stable diffusion model was developed using a pre-trained 2D text-to-image diffusion model to perform text-to-3D synthesis. We used probability density distillation loss to optimise a NeRF model using gradient descent. The resulting model can be viewed from any angle and requires no 3D training data or modifications to the image diffusion model. Because querying each ray in a NeRF requires a lot of computation we used a Sparse Neural Radiance Grid (SNeRG) that enables real-time rendering. This involved reformulation of the architecture using a sparse voxel grid representation with learned feature vectors. We used USDPython with ARConvert for Usdz compatibility on iOS.

The following papers were used as technical support and inspiration: 
- https://instruct-nerf2nerf.github.io/
- https://phog.github.io/snerg/
- https://dreamfusion3d.github.io/ 




