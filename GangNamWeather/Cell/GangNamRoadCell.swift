//
//  GangNamRoadCell.swift
//  GangNamWeather
//
//  Created by mobile on 2023/02/06.
//

import UIKit
import SnapKit

class GangNamRoadCell: UITableViewCell {
    var cellList: Document?
    var weatherInfo: OpenWeather?

    var address_name = UILabel() // 대여소 이름

    var x = UILabel() // 위도
    var y = UILabel() // 경도

    var nowTemp = UILabel() // 현재기온

    override func layoutSubviews() {
        super.layoutSubviews()
        [
            address_name, x, y
        ].forEach {
            contentView.addSubview($0)
        }

        guard let cellList = cellList else { return }
        //MARK: - Row
        address_name.text = cellList.addressName
        address_name.font = .systemFont(ofSize: 20, weight: .bold)
        address_name.textColor = .black

        //MARK: - OpenWeather
        nowTemp.text = String(weatherInfo?.current.temp ?? 0)
        nowTemp.font = .systemFont(ofSize: 14)
        nowTemp.textColor = .blue
        
        address_name.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(18)
        }

        x.snp.makeConstraints {
            $0.top.equalTo(address_name.snp.bottom).offset(10)
            $0.leading.equalTo(address_name.snp.leading)
        }
        
        y.snp.makeConstraints {
            $0.top.equalTo(x.snp.bottom).offset(10)
            $0.leading.equalTo(x.snp.leading)
        }

    }

}
