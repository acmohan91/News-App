//
//  Reachability.swift
//  News App
//
//  Created by Mohan AC on 13/02/22.
//

import Foundation
import Reachability

class Internet {
    
    private init() {}
    static let shared = Internet()
    private var reachability: Reachability!
    var isAvailable = false
    
    func stopNotifier() {
        self.reachability.stopNotifier()
    }
    
    func registerReachabilityNotifier() {
        self.reachability = try? Reachability()
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(self.reachabilityChanged),
                                               name: NSNotification.Name.reachabilityChanged,
                                               object: nil)
        
        do {
            try self.reachability.startNotifier()
        }
        catch (let error) {
            print("Error occured while starting reachability notifications : \(error.localizedDescription)")
        }
    }
    
    
    @objc func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi,.cellular:
            isAvailable = true
            print("Reachable via WiFi")
            NotificationCenter.default.post(name: NSNotification.Name.reachable, object: nil)
        case .none,.unavailable:
            isAvailable = false
            NotificationCenter.default.post(name: NSNotification.Name.reachable, object: nil)
            print("Network not reachable")
        }
    }
}

extension NSNotification.Name {
    static let reachable = NSNotification.Name("reachable")
}
