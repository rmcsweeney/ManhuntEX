//
//  ContentView.swift
//  ManhuntEX
//
//  Created by Ryan McSweeney on 4/2/22.
//

import SwiftUI
import CoreLocation




struct ContentView: View {
    var timer = Timer()
    let url = URL(string:"http://alecserv.com")!
    let DEBUG = true
    @State private var connected = Bool(false)
    @State private var user_ID = ""
    @State private var HTTP_DEBUG = "AWAITING VALUE"
    
    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea()
            VStack{
                Text("ManhuntEX")
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(Color.white)
                            .padding()
                TextField(" Enter Identification Code ", text: $user_ID)
                    .background()
                    .fixedSize()
                Button(action: connectToServer) {
                    Text(" Connect to Server ")
                }.disabled(connected || user_ID.isEmpty)
                    .background(Color.white)
                Text("Connection Status: " + (connected ? "Connected" : "Not Connected"))
                    .font(.caption)
                    .foregroundColor(Color.white).padding()
                if (DEBUG){
                    Text(HTTP_DEBUG)
                        .foregroundColor(Color.white)
                }
            }
                //.frame(maxWidth: .infinity, maxHeight: .infinity)
                //.accentColor(Color.black)
                //.background(Color.black)
        }
    }
    func connectToServer(){
        var request = URLRequest(url: url)
        let requestData = user_ID.data(using: .utf8)
        
        request.httpMethod = "POST"
        request.httpBody = requestData
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                connected = false
                HTTP_DEBUG = "HTTP error"
                return
            }
            else if let data = data {
                HTTP_DEBUG = String(decoding: data, as: UTF8.self)
                connected = true
                return
            }
            else {
                HTTP_DEBUG = "Unexpected error"
                connected = false
                return
            }
        }
        dataTask.resume()
    }
    
    func timerHandler() {
        
    }
        
    func startTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true, block: {_ in
            timerHandler()
        })
        
    }

    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
