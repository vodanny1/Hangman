//
//  ViewController.swift
//  Hangman
//
//  Created by Danny Vo on 2020-06-17.
//  Copyright © 2020 Danny Vo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var guess: UITextField!
    var letterButtons = [UIButton]()
    var numberOfGuessLabel: UILabel!
    var newGame: UIButton!
    var answer = ""
    var tempAnswer = ""
    var numberOfGuess = 7 {
        didSet {
            numberOfGuessLabel.text = "Guess Remaining: \(numberOfGuess)"
        }
    }
    var usedButtons = [UIButton]()
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        numberOfGuessLabel = UILabel()
        numberOfGuessLabel.translatesAutoresizingMaskIntoConstraints = false
        numberOfGuessLabel.textAlignment = .right
        numberOfGuessLabel.text = "Guess Remaining: \(numberOfGuess)"
        numberOfGuessLabel.font = numberOfGuessLabel.font.withSize(15)
        view.addSubview(numberOfGuessLabel)
        
        guess = UITextField()
        guess.translatesAutoresizingMaskIntoConstraints = false
        guess.textAlignment = .center
        guess.font = UIFont.systemFont(ofSize: 36)
        guess.isUserInteractionEnabled = false
        view.addSubview(guess)
        
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        
        newGame = UIButton()
        newGame.translatesAutoresizingMaskIntoConstraints = false
        newGame.setTitle("New Game", for: .normal)
        newGame.titleLabel?.font = .systemFont(ofSize: 15)
        newGame.setTitleColor(.blue, for: .normal)
        newGame.addTarget(self, action: #selector(restartGameTapped), for: .touchUpInside)
        view.addSubview(newGame)
        
        NSLayoutConstraint.activate([
            numberOfGuessLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            numberOfGuessLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            newGame.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            newGame.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            newGame.heightAnchor.constraint(equalTo: numberOfGuessLabel.heightAnchor),
            
            guess.topAnchor.constraint(equalTo: numberOfGuessLabel.bottomAnchor, constant: 150),
            guess.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            buttonsView.widthAnchor.constraint(equalToConstant: 300),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.topAnchor.constraint(equalTo: guess.bottomAnchor, constant: 150),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -100)
        ])
        
        let startingValue = Int(("A" as UnicodeScalar).value) // 65q
        
        let width = 50
        let height = 50
        var charCount = 0
        for row in 0..<4 {
            for column in 0..<6{
                let letterButton = UIButton(type: .system)
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                letterButton.setTitleColor(.gray, for: .normal)
                let char: Character = Character(UnicodeScalar(charCount + startingValue) ?? " ")
                
                letterButton.setTitle(String(char), for: .normal)
                letterButton.layer.borderWidth = 0.5
                letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
                
                
                let frame = CGRect(x: column * width, y: row * height, width: width, height: height)
                letterButton.frame = frame
                
                buttonsView.addSubview(letterButton)
                letterButtons.append(letterButton)
                charCount += 1
            }
        }
        for column in 2..<4{
            let letterButton = UIButton(type: .system)
            letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
            letterButton.setTitleColor(.gray, for: .normal)
            let char: Character = Character(UnicodeScalar(charCount + startingValue) ?? " ")

            letterButton.setTitle(String(char), for: .normal)
            letterButton.layer.borderWidth = 0.5
            letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)

            let frame = CGRect(x: column * width, y: 4 * height, width: width, height: height)
            letterButton.frame = frame

            buttonsView.addSubview(letterButton)
            letterButtons.append(letterButton)
            charCount += 1
        }
    }
    
    @objc func letterTapped(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else { return }
        usedButtons.append(sender)
        sender.isHidden = true
        
        if answer.contains(buttonTitle.lowercased()) {
            var indexArray = [Int]()
            var index = 0
            
            for char in answer {
                if char == Character(buttonTitle.lowercased()){
                    indexArray.append(index)
                }
                index += 1
            }
            
            var chars = Array(tempAnswer)
            for i in indexArray {
                chars[i] = Character(buttonTitle)
            }
            tempAnswer = String(chars)
            guess.placeholder = tempAnswer
            
            var count = 0
            for char in tempAnswer {
                if char == "?"{
                    count += 1
                }
            }
            if count == 0{
                let ac = UIAlertController(title: "Congratulations, you win!", message: "New game about to start", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
                restartGame()
            }
        } else {
            numberOfGuess -= 1
            if numberOfGuess == 0 {
                let ac = UIAlertController(title: "You lost!", message: "New game about to start", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
                restartGame()
            }
            
            let ac = UIAlertController(title: "Incorrect", message: "Minus 1 guess", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //startGame()
        performSelector(inBackground: #selector(startGame), with: nil)
    }
    
    @objc func startGame() {
        var word = ""
        if let fileURL = Bundle.main.url(forResource: "words", withExtension: "txt") {
            if let fileContent = try? String(contentsOf: fileURL){
                let lines = fileContent.components(separatedBy: "\n")
                
                let randInt = Int.random(in: 0...lines.count)
                word += lines[randInt]
                answer += word
                for _ in answer {
                    tempAnswer += "?"
                }
                DispatchQueue.main.async {
                    self.guess.placeholder = self.tempAnswer
                }
            }
        }
    }
    
    @objc func restartGameTapped(_ sender: UIButton){
        let ac = UIAlertController(title: "Game restarted", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Play again!", style: .default))
        present(ac, animated: true)
        restartGame()
    }
    func restartGame(){
        answer = ""
        tempAnswer = ""
        for b in usedButtons {
            b.isHidden = false
        }
        usedButtons.removeAll()
        numberOfGuess = 7
        performSelector(inBackground: #selector(startGame), with: nil)
    }


}

