//
//  UIKitDemoViewController.swift
//  PocketCoach
//

/// Standalone demo view controller demonstrating UIKit host integration.
final class UIKitDemoViewController: UIViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "UIKit Host Integration Demo"
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Demonstrating PocketCoach.makeViewController modal presentation."
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var launchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Launch Pocket Coach (UIKit)", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.20, green: 0.60, blue: 1.00, alpha: 1.0)
        button.layer.cornerRadius = 14
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapLaunch), for: .touchUpInside)
        return button
    }()

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "No session completed yet."
        label.textColor = .gray
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.07, green: 0.08, blue: 0.11, alpha: 1.0)
        setupViews()
    }

    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(launchButton)
        view.addSubview(resultLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            launchButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            launchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            launchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            launchButton.heightAnchor.constraint(equalToConstant: 52),

            resultLabel.topAnchor.constraint(equalTo: launchButton.bottomAnchor, constant: 24),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    @objc private func didTapLaunch() {
        let pocketCoachVC = PocketCoach.makeViewController { [weak self] result in
            if let result = result {
                self?.resultLabel.text = "Session Completed: \(result.exercise.name)\n\(result.completedReps) reps (\(result.repsWithErrors) with errors)"
                self?.resultLabel.textColor = .white
            } else {
                self?.resultLabel.text = "Session dismissed by user without completion."
                self?.resultLabel.textColor = .lightGray
            }
        }
        present(pocketCoachVC, animated: true)
    }
}
