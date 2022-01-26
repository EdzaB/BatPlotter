//
//  SplashScreenViewController.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 17/01/2022.
//

import UIKit

// MARK: Props
final class SplashScreenVC: UIViewController {
    var viewModel: PSplashScreenVM?
    var spinnerView = UIActivityIndicatorView()
}

// MARK: View life cycle
extension SplashScreenVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpinner()
        setupBackground()
        viewModel?.onErrorOccur = { [weak self] errorString in
            self?.handleAlert(with: errorString)
        }
        onVMSyncComplete()
    }

    private func setupSpinner() {
        view.addSubview(spinnerView)
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        spinnerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.frame.height / 3).activate()
        spinnerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).activate()
        spinnerView.constrainAspectRatio(to: 1)
        spinnerView.heightAnchor.constraint(equalToConstant: 50).activate()
        spinnerView.color = .white
        spinnerView.hidesWhenStopped = false
        spinnerView.startAnimating()

    }

    private func setupBackground() {
        view.backgroundColor = .black
    }
}

// MARK: On Sync complete
extension SplashScreenVC {
    private func onVMSyncComplete() {
        viewModel?.onSyncCompletion = { [weak self] in
            DispatchQueue.main.async {
                UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
                    self?.spinnerView.stopAnimating()
                    self?.spinnerView.alpha = 0
                }, completion: { _ in
                    self?.viewModel?.navigateToUserList?()
                })
            }
        }
    }

    private func handleAlert(with errorString: String) {
        let alert = UIAlertController(title: "Please try again later!", message: errorString, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
