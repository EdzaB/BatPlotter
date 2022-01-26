//
//  UserListCell.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 21/01/2022.
//

import UIKit
import Kingfisher

final class UserListCell: UITableViewCell {
    static let nib = UINib(nibName: UserListCell.identifier, bundle: nil)
    static let identifier = String(describing: UserListCell.self)
    
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    func configureCell(user: UserDO?) {
        guard let user = user else { return }

        titleLabel.text = "\(user.name) \(user.surname)"
        userImageView.kf.setImage(with: user.url)
    }
}
