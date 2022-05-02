//
//  ContentView.swift
//  ManhuntEX
//
//  Created by Ryan McSweeney on 4/2/22.
//

import SwiftUI
import CoreLocation
import Foundation



struct ContentView: View {
    //@State var timer: Timer!
    let url = URL(string:"http://manhunt.alecn.net/loc/")!
    let urlString = "http://manhunt.alecn.net/loc/"
    let DEBUG = false
    @StateObject var locationManager = LocationManager()
    @State private var connected = Bool(false)
    @State private var user_ID = ""
    @State private var HTTP_DEBUG = "AWAITING VALUE"
    @State private var sent_latitude = "WAITING TO SEND A LATITUDE"
    @State private var sent_longitude = "WAITING TO SEND A LONGITUDE"
    @State private var DEBUG_LAT = " Awaiting "
    @State private var DEBUG_LONGI = " Awaiting "
    @State private var curLat = ""
    @State private var curLong = "1"
    @State private var started = false
    @State private var timerStarted = false
    @State private var interrupts = 0
    
    let timer = Timer.publish(every: 15, tolerance: 3, on: .main, in: .common).autoconnect()
    
    init(){
        
    }
    
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
                }.disabled(user_ID.isEmpty || curLong.elementsEqual("nan"))
                    .background(Color.white)
                Text("Connection Status: " + (connected ? "Connected" : "Not Connected"))
                    .font(.caption)
                    .foregroundColor(Color.white).padding()
                Button(action: testLocation){
                    Text(" Locally update location ")
                }
                Text("Lat: " + DEBUG_LAT).foregroundColor(Color.white)
                Text("Long: " + DEBUG_LONGI).foregroundColor(Color.white)
                Text("Timer has updated: " + String(interrupts) + " times").foregroundColor(Color.white).onReceive(timer) {
                    _ in
                    if (connected){
                        connectToServer()
                    }
                    interrupts += 1
                }
                if (DEBUG){
                    Button(action: timerHandler){
                        Text(" Manually send location ")
                    }.disabled(!connected).background(Color.white)
                    Text(HTTP_DEBUG)
                        .foregroundColor(Color.white)
                    Text(sent_latitude).foregroundColor (Color.white)
                    Text(sent_longitude).foregroundColor(Color.white)
                }
            }
                //.frame(maxWidth: .infinity, maxHeight: .infinity)
                //.accentColor(Color.black)
                //.background(Color.black)
        }
    }
    
    func testLocation(){
        if (!started){
            locationManager.startUpdating()
            started = true
        }
        locationManager.requestLocation()
        let loc = locationManager.lastKnownLocation?.coordinate
        DEBUG_LAT = String(format: "%f", Double(loc?.latitude ?? -1))
        curLat = DEBUG_LAT
        DEBUG_LONGI = String(format: "%f", loc?.longitude ?? -1)
        curLong = DEBUG_LONGI
    }
    
    func connectToServer(){
        //locationManager.manager.requestWhenInUseAuthorization()
        testLocation()
        //while (curLong.elementsEqual("nan")){
        //    testLocation()
        //}
        let urlConn = URL(string:"http://manhunt.alecn.net/loc/" + user_ID + "," + curLat +  "," + curLong)!
        var request = URLRequest(url: urlConn)
        let requestData = user_ID + ",0,0"//user_ID.data(using: .utf8)
        //requestData = user_ID + ",0,0"
        request.httpMethod = "POST"
        request.httpBody = requestData.data(using: .utf8)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                connected = false
                HTTP_DEBUG = "HTTP error"
                return
            }
            else if let data = data {
                HTTP_DEBUG = String(decoding: data, as: UTF8.self)
                connected = true
//                if (!timerStarted){
//                    startTimer()
//                }
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
        
        var request = URLRequest(url: url)
        locationManager.requestLocation()
        let loc = locationManager.lastKnownLocation?.coordinate
        //let requestData: (Double, Double) = (Double(loc?.latitude ?? 0), Double(loc?.longitude ?? 0))
        let lat: String = String(format: "%f", Double(loc?.latitude ?? -1))
        let longi: String = String(format: "%f", loc?.longitude ?? -1)
        let requestData = user_ID + "," + lat + "," + longi
        request.httpMethod = "POST"
        request.httpBody = requestData.data(using: .utf8)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                connected = false
                HTTP_DEBUG = "HTTP error"
                return
            }
            else if let data = data {
                HTTP_DEBUG = String(decoding: data, as: UTF8.self)
                connected = true
                if (!timerStarted){
                    startTimer()
                }
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
        
    func startTimer() {
        //timer.invalidate()
        //timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true, block: {_ in
            connectToServer()
        //})
        timerStarted = true
    }

}

protocol locationManagerDelegate{
    func locationManager(_ manager: CLLocationManager,
             didFailWithError error: Error)
    
    func locationManager(_ manager: CLLocationManager,
                                  didUpdateLocations locations: [CLLocation])
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    public let manager = CLLocationManager()
    @Published var lastKnownLocation: CLLocation?
    
    func startUpdating() {
        self.manager.delegate = self
        self.manager.requestWhenInUseAuthorization()
        self.manager.startUpdatingLocation()
        self.manager.allowsBackgroundLocationUpdates = true
        self.manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager,
                                  didFailWithError error: Error){
        return
    }
    
    func requestLocation() {
        self.manager.requestLocation()
    }
}
