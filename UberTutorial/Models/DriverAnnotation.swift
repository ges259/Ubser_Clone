//
//  DriverAnnotation.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/20.
//

import MapKit

final class DriverAnnotation: NSObject, MKAnnotation {
    // 동적 변수로 만들어야 스스로 업데이트를 할 수 있다.
    dynamic var coordinate: CLLocationCoordinate2D
    var uid: String
    
    init(uid: String, coordinate: CLLocationCoordinate2D) {
        self.uid = uid
        self.coordinate = coordinate
    }
    
    
    // 주석을 업데이트할 때 사용하는 함수
        // driver의 위치가 바뀌면 -> 이 함수가 호출
            // 그에 따라 driver의 위치를 화면에 재설정
    func updateAnnotationPosition(withCoodinate coordinate: CLLocationCoordinate2D) {
        
        UIView.animate(withDuration: 0.2) {
            self.coordinate = coordinate
        }
    }
}
