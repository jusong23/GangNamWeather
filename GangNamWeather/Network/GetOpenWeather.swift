//
//  GetOpenWeather.swift
//  GangNamWeather
//
//  Created by mobile on 2023/02/06.
//

import Foundation
import RxSwift
import RxCocoa

class GetOpenWeather {
    func getWeatherInfo(lat:Double, lon:Double) -> Observable<OpenWeather> { // 🔩 model struct name
        return Observable.create { (emitter) in
            let weatherUrlStr = "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lon)&exclude=hourly&appid=70712209ed38b3c9995cdcdd87bda250&units=metric" // 🔩 url

            // [1st] URL instance 작성
            guard let url = URL(string: weatherUrlStr) else {
                emitter.onError(SimpleError())
                return Disposables.create()
            }

            // [2nd] Task 작성(.resume)
            let session = URLSession.shared
            let task = session.dataTask(with: url) { data, response, error in
                // error: 에러처리
                if let error = error { return }
                // response: 서버 응답 정보
                guard let httpResponse = response as? HTTPURLResponse else { return }
                guard (200 ... 299).contains(httpResponse.statusCode) else { return }

                // data: 서버가 읽을 수 있는 Binary 데이터
                guard let data = data else { fatalError("Invalid Data") }

                do {
                    let decoder = JSONDecoder()
                    let weatherInfo = try decoder.decode(OpenWeather.self, from: data) // 🔩 model struct name
                    emitter.onNext(weatherInfo)
                    emitter.onCompleted()
                } catch {
                    emitter.onError(SimpleError())
                }
            }
            task.resume() // suspend 상태의 task 깨우기
            
            return Disposables.create()
        }
    }
}

