//
//  ViewController.swift
//  Project5
//
//  Created by Enrique Casas on 9/8/21.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        let defaults = UserDefaults.standard
        title = defaults.string(forKey: "title")

        if title == nil || title == "No title" {
            startGame()
        } else {
            print("HELP ME PLEASE")
            if let savedWordList = defaults.object(forKey: "UsedWords") as? Data {
                let jsonDecoder = JSONDecoder()
                print("HELP ME")
                do {
                    usedWords = try jsonDecoder.decode([String].self, from: savedWordList)
                    print("HELP")
                } catch {
                    print("failed to load")
                }
            }
        }
        
//        if ((title?.isEmpty) != nil) {
//            startGame()
//        } else {
//            let defaults = UserDefaults.standard
//            title = defaults.string(forKey: "title")
//
//            print("HELP ME PLEASE")
//            if let savedWordList = defaults.object(forKey: "UsedWords") as? Data {
//                let jsonDecoder = JSONDecoder()
//                print("HELP ME")
//                do {
//                    usedWords = try jsonDecoder.decode([String].self, from: savedWordList)
//                    print("HELP")
//                } catch {
//                    print("failed to load")
//                }
//            }
//        }
        
        
        
        //startGame()
        

    }
    
    @objc func startGame() {
        title = allWords.randomElement()
        saveTitle(title: title ?? "No title")
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            // ADD ANSWER TO ARRAY FOR USERDEFAULTS
            self?.submit(answer)
            }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
        }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        let errorTitle: String
        let errorMessage: String
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(lowerAnswer, at: 0)
                    saveWords()
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                } else {
                    errorTitle = "Word not recognized"
                    errorMessage = "You can't just make them up, you know!"
                    showErrorMessage(message: errorMessage, errorTitle: errorTitle)
                }
            } else {
                errorTitle = "Word used already"
                errorMessage = "Be more original!"
                showErrorMessage(message: errorMessage, errorTitle: errorTitle)
            }
        } else {
            guard let title = title?.lowercased() else { return }
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from \(title)"
            showErrorMessage(message: errorMessage, errorTitle: errorTitle, title: title)
        }
        
        /* let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true) */
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else {return false}
        
        if word == tempWord {
            return false
        } else {
            for letter in word {
                if let position = tempWord.firstIndex(of: letter) {
                    tempWord.remove(at: position)
                } else {
                    return false
                }
            }
            return true
        }
    }
    
    func isOriginal(word: String) -> Bool {
        /*let lowercasedWord = word.lowercased()
        print(lowercasedWord) */
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        
        if word.count < 3 {
            return false
        } else {
            let checker = UITextChecker()
            let range = NSRange(location: 0, length: word.utf16.count)
            let misspelledRange = checker.rangeOfMisspelledWord (in: word, range: range, startingAt: 0, wrap: false, language: "en")
            return misspelledRange.location == NSNotFound
        }
    }
    
    func showErrorMessage(message: String, errorTitle: String, title: String = "") {
        let ac = UIAlertController(title: errorTitle, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func saveTitle(title: String) {
        let defaults = UserDefaults.standard
        defaults.set(title, forKey: "title")
    }
    
    func saveWords() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(usedWords) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "UsedWords")
        }
    }

}

