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
    @State var timer: Timer!
    let url = URL(string:"http://alecserv.com")!
    let DEBUG = true
    @StateObject var locationManager = LocationManager()
    @State private var connected = Bool(false)
    @State private var user_ID = ""
    @State private var HTTP_DEBUG = "AWAITING VALUE"
    @State private var sent_latitude = "WAITING TO SEND A LATITUDE"
    @State private var sent_longitude = "WAITING TO SEND A LONGITUDE"
    @State private var DEBUG_LAT = " Awaiting "
    @State private var DEBUG_LONGI = " Awaiting "
    
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
                }.disabled(connected || user_ID.isEmpty)
                    .background(Color.white)
                Text("Connection Status: " + (connected ? "Connected" : "Not Connected"))
                    .font(.caption)
                    .foregroundColor(Color.white).padding()
                if (DEBUG){
                    Button(action: timerHandler){
                        Text(" Manually send location ")
                    }.disabled(!connected).background(Color.white)
                    Text(HTTP_DEBUG)
                        .foregroundColor(Color.white)
                    Text(sent_latitude).foregroundColor (Color.white)
                    Text(sent_longitude).foregroundColor(Color.white)
                    Button(action: testLocation){
                        Text(" Locally update location ")
                    }
                    Text("Lat: " + DEBUG_LAT).foregroundColor(Color.white)
                    Text("Long: " + DEBUG_LONGI).foregroundColor(Color.white)
                }
            }
                //.frame(maxWidth: .infinity, maxHeight: .infinity)
                //.accentColor(Color.black)
                //.background(Color.black)
        }
    }
    
    func testLocation(){
        locationManager.startUpdating()
        locationManager.requestLocation()
        let loc = locationManager.lastKnownLocation?.coordinate
        DEBUG_LAT = String(format: "%f", Double(loc?.latitude ?? -1))
        DEBUG_LONGI = String(format: "%f", loc?.longitude ?? -1)
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
                startTimer()
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
        let requestData = lat + " " + longi
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
                startTimer()
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
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true, block: {_ in
            timerHandler()
        })
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
    private let manager = CLLocationManager()
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
