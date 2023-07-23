//
//  Service.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/19.
//

import FirebaseCore
import FirebaseAuth
//import FirebaseDatabase
import GeoFire
import CoreLocation

struct Service {
    
    
    // MARK: - Properties
    // 싱글톤
    static let shared = Service()
    init() {}
    
    
    
    
    // MARK: - API
    func fetchUserData(uid: String,completion: @escaping (User) -> Void) {
        REF_USERS.child(uid).observeSingleEvent(of: .value) { snapshot in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let uid = snapshot.key
            
            let user = User(uid: uid,dictionary: dictionary)
            
            // completion
            completion(user)
        }
    }
    
    func fetchDrivers(location: CLLocation, completion: @escaping(User) -> Void) {
        
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)

        REF_DRIVER_LOCATIONS.observe(.value) { snapshot in
            
            geofire.query(at: location, withRadius: 50).observe(.keyEntered, with: { uid, location in
                
                self.fetchUserData(uid: uid) { user in
                    var driver = user
                    driver.location = location
                    completion(driver)
                }
            })
        }
    }
    
    
    // 유저(passenger)의 위치와 도착지의 위치를 DB에 넣는 과정
    func uploadTrip(_ pickerCoordinates: CLLocationCoordinate2D,
                    _ destinationCoordinates: CLLocationCoordinate2D,
                    completion: @escaping (Error?, DatabaseReference) -> Void) {
        // user id
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // 출발지의 위도와 경도 구하기
        let pickerArray = [pickerCoordinates.latitude, pickerCoordinates.longitude]
        // 도착지의 위도와 경도 구하기
        let destinationArray = [destinationCoordinates.latitude, destinationCoordinates.longitude]
        
        // 데이터베이스에 저장할 데이터 values에 넣기
        let values = [DB_String.pickerCoordinates: pickerArray,
                      DB_String.destinationCoordinates: destinationArray,
                      DB_String.state: TripState.requested.rawValue] as [String: Any]
        
        REF_TRIPS.child(uid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    
    
    
    // 사용자가 driver인 경우
        // passenger가 uploadTrip을 사용할 경우
        // observe(.childAdded)를 통해서 통보를 받음
            // 화면 전환
    func observeTrips(completion: @escaping (Trip) -> Void) {
        // observe(.childAdded) <<<<<----- 중요!!!
        REF_TRIPS.observe(.childAdded) { snapshot in
            // snapshot.value를 통해서
            // 출발지와 도착지의 정보를 받아온다.
                // Trip을 사용하여 모델을 만들고
                    // completion을 이용하여 반환
                        // 반환된 trip은 didSet이 실행 됨
                            // 화면 전환
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            let uid = snapshot.key
            let trip = Trip(passenerUid: uid, dictionary: dictionary)
            
            completion(trip)
        }
    }
    
    // 사용자가 driver인 경우
    // driver가 passenger의 요청을 받으면 ( ACCEPT TRIP 버튼을 클릭 )
        // DB의 state가 .accept로 바뀜
            // 그러면 passenger는 대기 화면에서 -> 메인 화면으로 돌아감
    func acceptTrip(trip: Trip, completion: @escaping (Error?, DatabaseReference) -> Void) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = [DB_String.driverUid: uid,
                      DB_String.state: TripState.accepted.rawValue] as [String : Any]
        
        REF_TRIPS.child(trip.passenerUid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    
    
    
    // 사용자가 passenger인 경우
        // passenger에게 trip의 현재 상태를 알려주는 함수
            // loadingView를 끊어준다.
    func observeCurrentTrip(completion: @escaping (Trip) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        REF_TRIPS.child(uid).observe(.value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            let uid = snapshot.key
            let trip = Trip(passenerUid: uid, dictionary: dictionary)
            completion(trip)
        }
    }
}
