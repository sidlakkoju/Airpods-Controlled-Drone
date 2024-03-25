import SwiftUI
import CoreMotion
import SceneKit

// Tello Stuff
import CocoaAsyncSocket

struct ContentView: View {
    
    @StateObject private var viewModel = ViewModel()
    
    private let scene = SCNScene()
    private let cubeNode = SCNNode()
    private let planeNodeParent = SCNNode()
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                SceneView(
                    scene: scene,
                    pointOfView: nil,
                    options: [.autoenablesDefaultLighting, .allowsCameraControl],
                    delegate: nil,
                    technique: nil
                )
                .background(Color.black)
                .frame(height: geometry.size.height / 2)
                .onAppear {
                    setupScene()
                }
                .onChange(of: viewModel.cubeRotation) {
                    cubeNode.eulerAngles = SCNVector3(viewModel.cubeRotation[0], viewModel.cubeRotation[1], -1*viewModel.cubeRotation[2])
                    planeNodeParent.eulerAngles = SCNVector3(-1*viewModel.cubeRotation[0] + .pi / 2, -1*viewModel.cubeRotation[1], -1*viewModel.cubeRotation[2] + .pi)
                }

                Spacer()
                
                VStack{
                    
                    Text(viewModel.direction)
                        .font(.system(size: 50))
                        .padding()
                    
                    HStack {
                        Button(action: {
                            viewModel.takeOff()
                        }) {
                            Text("Take Off")
                        }
                        .buttonStyle(CustomButtonStyle(backgroundColor: .green))
                        .padding(.horizontal, 8)
                        
                        Button(action: {
                            viewModel.land()
                        }) {
                            Text("Land")
                        }
                        .buttonStyle(CustomButtonStyle(backgroundColor: .yellow))
                        .padding(.horizontal, 8)
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    
                    Button(action: {
                        viewModel.emergency()
                    }) {
                        Text("Emergency")
                    }
                    .buttonStyle(CustomButtonStyle(backgroundColor: .red))
                    .padding(.top, 40)
                }
                .frame(height: geometry.size.height / 2)
                .contentShape(Rectangle())
            }
            .onAppear {
                viewModel.startMonitoring()
                viewModel.setupTello()
            }
            .onDisappear {
                viewModel.stopMonitoring()
            }
        }
    }
    
    private func setupScene() {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
//        cameraNode.position = SCNVector3(x: 0, y: 0, z: 60)
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        scene.rootNode.addChildNode(cameraNode)

        let cubeGeometry = SCNBox(width: 3, height: 3, length: 3, chamferRadius: 0.5)

        guard let planeScene = SCNScene(named: "B_787_8.dae") else {
            return
        }

        // Create a parent node to hold all the child nodes from the planeScene
        cubeNode.geometry = cubeGeometry
        cubeNode.name = "cube"
        scene.rootNode.addChildNode(cubeNode)
        

//        // Add all the child nodes from the planeScene to the planeNodeParent
//        for childNode in planeScene.rootNode.childNodes {
//            planeNodeParent.addChildNode(childNode)
//        }
//
//        // Rotate the planeNodeParent
//        planeNodeParent.eulerAngles.x = .pi / 2 // Rotate 90 degrees along the x-axis
//        planeNodeParent.eulerAngles.z = .pi // Rotate 180 degrees along the z-axis
//        
//        // Translate the planeNodeParent
//        planeNodeParent.position.x = -5 // Translate 20 units along the x-axis
//        planeNodeParent.position.y = -15 // Translate 20 units along the y-axis
//
//        // Add the planeNodeParent to the current scene's root node
//        scene.rootNode.addChildNode(planeNodeParent)
        scene.background.contents = NSColor.background
    }
}

struct CustomButtonStyle: ButtonStyle {
    var backgroundColor: Color // Add a background color property
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.system(size: 20))
            .frame(width: 120, height: 50) // Specify the desired width and height
            .foregroundColor(.white)
            .background(backgroundColor) // Use the background color here
            .cornerRadius(5)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

#Preview {
    ContentView()
}

