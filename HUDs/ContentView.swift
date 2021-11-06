//
//  ContentView.swift
//  HUDs
//
//  Created by Atakan Cengiz KURT on 6.11.2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Home()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct Home: View{
    var body: some View{
        NavigationView{
            List{
                ForEach(1...30, id: \.self){
                    index in
                    NavigationLink{
                        Text("Detail Page \(index)")
                            .navigationTitle("Detail")
                    }label: {
                        Text("Navigate to Page \(index)")
                    }
                }
            }
            .navigationTitle("Home")
            .toolbar {
                Button("Show HUD") {
                    showHUD(image: "airpodspro", color: .green, title: "Connected") { status, msg in
                        if !status{
                            print(msg)
                        }
                    }
                    
                }
            }
        }
        
    }
}


extension View{
    //extracting Root Controller
    func getRootController()->UIViewController{
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        
        guard let root = screen.windows.last?.rootViewController else{
            return .init()
        }
        return root
    }
    
    func getRect()-> CGRect{
        return UIScreen.main.bounds
    }
    
    func showHUD(image: String, color: Color = .primary, title: String, completion: @escaping (Bool,String)-> ()){
        
        //Avoiding multiple HUDs
        if getRootController().view.subviews.contains(where: { view in
            return view.tag == 1009
        }){
            completion(false,"Already Presenting!")
            return
        }
        
        //Converting swiftui view to UIKit
        let hudViewController = UIHostingController(rootView: HUDView(image: image, color: color, title: title))
        
        //Content size
        let size = hudViewController.view.intrinsicContentSize
        hudViewController.view.frame.size = size
        hudViewController.view.backgroundColor = .clear
        
        //Setting center
        hudViewController.view.frame.origin = CGPoint(x: (getRect().width / 2) - (size.width/2), y: 50)
        
        //Setting tag
        hudViewController.view.tag = 1009
        
        //Adding to root
        getRootController().view.addSubview(hudViewController.view)
    }
}


struct HUDView: View{
    var image: String
    var color: Color
    var title: String
    
    @Environment(\.colorScheme) var scheme
    @State var showHud:Bool = false
    
    var body: some View{
        HStack(spacing: 10){
            Image(systemName: image)
                .font(.title3)
                .foregroundColor(color)
            
            Text(title)
                .foregroundColor(.primary)
        }
        .padding(.vertical,10)
        .padding(.horizontal)
        .background(
            scheme == .dark ? Color.black : Color.white
        )
        .clipShape(Capsule())
        //Shadows
        .shadow(color: Color.primary.opacity(0.1), radius: 5, x: 1, y: 5)
        .shadow(color: Color.primary.opacity(0.03), radius: 5, x: 0, y: -5)
        //Moving to top
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .offset(y: showHud ? 0 : -200)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)){
                showHud = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.5)){
                    showHud = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    getRootController().view.subviews.forEach { view in
                        //Removing view
                        if view.tag == 1009{
                            view.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }
}
