//
//  ViewController.swift
//  GangNamWeather
//
//  Created by mobile on 2023/02/06.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ViewController: UIViewController {
    private let gangNamRoad = PublishSubject<GangNamRoad>()
    private var document = BehaviorSubject<[Document]>(value: [])
    private let openWeather = PublishSubject<OpenWeather>()

    private let disposeBag = DisposeBag()

    var getOpenWeather = GetOpenWeather()

    var newAddressName = UILabel() // 도로명주소
    var addressName = UILabel() // 지번주소
    var latitude = UILabel() // 위도
    var longitude = UILabel() // 경도
    
    // safe area
    let safetyArea: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()

    var temperature = UILabel() // 현재기온

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationBar()
        setUI()
    }

    func setUI() {
        safetyArea.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safetyArea)

        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            safetyArea.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
            safetyArea.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
            safetyArea.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
            safetyArea.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true

        } else {
            safetyArea.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor).isActive = true
            safetyArea.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor).isActive = true
            safetyArea.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            safetyArea.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }

        [newAddressName, addressName, latitude, longitude, temperature].forEach {
            safetyArea.addSubview($0)
        }

        view.setNeedsUpdateConstraints()
    }

    func setUpNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = .gray
        self.navigationItem.title = "강남역 날씨 데이터"
        view.backgroundColor = .white

        let rightButton = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(getData))
        self.navigationItem.rightBarButtonItem = rightButton

        navigationItem.rightBarButtonItem = rightButton
    }


    @objc func getData() {
        self.fetchRentBikeStatus(of: "%EC%84%9C%EC%9A%B8%ED%8A%B9%EB%B3%84%EC%8B%9C%20%EA%B0%95%EB%82%A8%EA%B5%AC%20%EA%B0%95%EB%82%A8%EB%8C%80%EB%A1%9C%20396")
    }

    func fetchRentBikeStatus(of fetchedLocation: String) {
        Observable.from([fetchedLocation])
        // 배열의 인덱스를 하나하나 방출
        .map { fetchedLocation -> URL in
            // 타입을 변경할 때도 map이 유용하다. (Array -> URL)
            return URL(string: "https://dapi.kakao.com/v2/local/search/address.json?query=\(fetchedLocation)")!
        }
        //MARK: - Request
        .map { url -> URLRequest in
            print("url: \(url) thread in url: \(Thread.isMainThread)")
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("KakaoAK 4e78ea35cffb481201121cd3d09455a6", forHTTPHeaderField: "Authorization")
            return request
        }
        // URL -> URLRequest
        .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
            return URLSession.shared.rx.response(request: request)
        }
        // Tuple의 형태의 Observable 시퀀스로 변환 Observable<(response,data)>.  ... Observable<Int> 처럼
        //MARK: - Response
        .filter { response, _ in
            // Tuple 내에서 response만 받기 위해 _ 표시
            return 200..<300 ~= response.statusCode
            // responds.statusCode가 해당범위에 해당하면 true
        }
            .map { _, data -> GangNamRoad in
            let decoder = JSONDecoder()
            if let json = try? decoder.decode(GangNamRoad.self, from: data) {
                print("json: \(json)")
                return json
            }
            throw SimpleError()
        } // MARK: - 배열만 뽑아내는(배열 타입으로 바꾸는, document가 배열 타입의 Subject) Tric
        .map { jsonObjects -> [Document] in // compactMap: 1차원 배열에서 nil을 제거하고 옵셔널 바인딩
            //throw SimpleError() //MARK: map안에서의 에러 표현

            print("jsonObjects: \(jsonObjects)")

            return jsonObjects.documents
        }
            .flatMap { arrDocument -> Observable<([Document], OpenWeather)> in
//            let lat = Double(arrDocument.first!.x)!
//            let lon = Double(arrDocument.first!.y)!

            let lat = 37.5492 // 위에꺼 반올림하기
            let lon = 126.9232 // 위에꺼 반올림하기

            return self.getOpenWeather.getWeatherInfo(lat: lat, lon: lon)
                .map { openWeather -> ([Document], OpenWeather) in
                return (arrDocument, openWeather)
            }
        }
            .subscribe(on: ConcurrentDispatchQueueScheduler(queue: .global())) // Observable 자체 Thread 변경
        .observe(on: MainScheduler.instance) // 이후 subsribe의 Thread 변경
        .subscribe { event in // MARK: 에러처리에 용이한 subscribe 트릭
            switch event {
            case .next(let (newGangNamRoad, openWeather)):
                self.document.onNext(newGangNamRoad)
                self.openWeather.onNext(openWeather)
//                print(newGangNamRoad)
//                print(openWeather.current.temp)
                self.autolayoutConfiguration(newAddressName: newGangNamRoad.first!.address.addressName, addressName: newGangNamRoad.first!.addressName, latitude: newGangNamRoad.first!.x, longitude: newGangNamRoad.first!.y, temperature: String(openWeather.current.temp!))
                // BehaviorSubject에 이벤트 발생
            case .error(let error):
                print("error: \(error), thread: \(Thread.isMainThread)")
            case .completed:
                print("completed")
            }
        }
            .disposed(by: disposeBag)
    }
}

extension ViewController {
    // 도로명 주소, 지번 주소 , 위도 경도 °
    func autolayoutConfiguration(newAddressName: String, addressName: String, latitude: String, longitude: String, temperature:String) {
        safetyArea.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safetyArea)

        self.newAddressName.text = newAddressName
        self.newAddressName.font = .systemFont(ofSize: 28, weight: .bold)
        self.newAddressName.textColor = .black

        self.addressName.text = "도로명주소: " + addressName
        self.addressName.font = .systemFont(ofSize: 14, weight: .light)
        self.addressName.textColor = .systemGray

        self.latitude.text = "위도: " + latitude + "°"
        self.latitude.font = .systemFont(ofSize: 20)
        self.latitude.textColor = .black

        self.longitude.text = "경도: " + longitude + "°"
        self.longitude.font = .systemFont(ofSize: 20)
        self.longitude.textColor = .black

        self.temperature.text = temperature + "°C"
        self.temperature.font = .systemFont(ofSize: 20)
        self.temperature.textColor = .blue
        
        self.newAddressName.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(18)
        }

        self.addressName.snp.makeConstraints {
            $0.top.equalTo(self.newAddressName.snp.bottom).offset(4)
            $0.leading.equalTo(self.newAddressName.snp.leading)
        }

        self.latitude.snp.makeConstraints {
            $0.top.equalTo(self.addressName.snp.bottom).offset(10)
            $0.leading.equalTo(self.addressName.snp.leading)
        }

        self.longitude.snp.makeConstraints {
            $0.top.equalTo(self.latitude.snp.bottom).offset(10)
            $0.leading.equalTo(self.latitude.snp.leading)
        }
        
        self.temperature.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(18)
        }
    }
}

#if DEBUG
    import SwiftUI
    struct ViewController_Representable: UIViewControllerRepresentable {

        func updateUIViewController(_ uiView: UIViewController, context: Context) {
            // leave this empty
        }
        @available(iOS 13.0.0, *)
        func makeUIViewController(context: Context) -> UIViewController {
            ViewController() // ✅
        }
    }
    @available(iOS 13.0, *)
    struct ViewController_Representable_PreviewProvider: PreviewProvider {
        static var previews: some View {
            Group {
                ViewController_Representable()
                    .ignoresSafeArea()
                    .previewDisplayName("ViewController") // ✅
                .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro")) // ✅
            }

        }
    }#endif
