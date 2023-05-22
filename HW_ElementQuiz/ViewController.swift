//
//  ViewController.swift
//  HW_ElementQuiz
//
//  Created by 曹家瑋 on 2023/5/20.
//

/*
 0. 多題取10
 1. 選擇題：顯示當前題目、當前題目的選項。 (for迴圈)
 2. 選完選項，按鈕會無效化。需要按下一頁，選項才會在啟用。 (for迴圈)
 3. 答對得分，顯示在(scoreLabel)。
 4. 當前選項結果顯示(optionsResultLabel)。
 5. 顯示得分結果：級距
 6. 重新開始（shuffle)。

 */

import UIKit
import AVFoundation

class ViewController: UIViewController {

    // 當前第幾題
    @IBOutlet weak var titleNumberLabel: UILabel!
    // 題目內容
    @IBOutlet weak var questionContentLabel: UILabel!
    // 選項結果提示
    @IBOutlet weak var answerResultLabel: UILabel!
    // 分數
    @IBOutlet weak var scoreLabel: UILabel!
    // 結果顯示
    @IBOutlet weak var scoreResultLabel: UILabel!

    // 三個選項的 UIButton 陣列
    @IBOutlet var optionButtons: [UIButton]!
    // 下一題
    @IBOutlet weak var nextButton: UIButton!
    // 重新開始Button
    @IBOutlet weak var restartButton: UIButton!

    // 用於存儲題目
    var questions = [MultipleChoiceQuestion]()

    // 用來儲存會顯示出來的題目
    var currentQuestions = [MultipleChoiceQuestion]()

    // 控制當前題目的索引位置
    var index = 0

    // 分數追蹤 (答對時可以加分）
    var score = 0

    // 播放音效
    let soundPlayer = AVPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        initQuestions()                                  // 題目、選項、正確答案列表

        restartButton.isHidden = true                    // 預設：重新開始Button隱藏，到最後一題，才會顯示。
        nextButton.isHidden = true                       // 預設：nextButton先隱藏，必須做出選擇才會顯示。
        scoreResultLabel.isHidden = true                 // 預設：隱藏得分結果顯示

        restartGameButtonPressed(restartButton)          // 調用重新開始函數來進行題目洗牌和畫面設定
    }


    // 正確答案
    @IBAction func correctAnswerButton(_ sender: UIButton) {

        let answer = currentQuestions[index].correctAnswerText     // 宣告一個正確答案的陣列

        // 判斷是否正確答案
        if sender.title(for: .normal) == answer {
            answerResultLabel.text = "你答對了！"                   // 正確：選項結果提示
            score = score + 10                                     // 答對加10分
            scoreLabel.text = "目前得分： \(score) 分"

            correctSound()                                          // 正確答案音效

        } else {
            answerResultLabel.text = "不要瞎猜好嗎！"                // 錯誤：選項結果提示

            wrongSound()                                           // 答錯答案音效
        }

        // 選擇完成後，禁用所有選項按鈕，直到進入下一題或重新開始遊戲。
        for button in optionButtons {
            button.isEnabled = false
        }

        // 檢查是否為最後一題
        if index == currentQuestions.count - 1 {
            restartButton.isHidden = false                          // 是最後一題，顯示 restartButton按鈕
            questionContentLabel.isHidden = true                    // 是最後一題，隱藏 題目

            getScoreResultText()                                    // 取得評分結果

        } else {
            nextButton.isHidden = false                             // 不是最後一題，顯示nextButton按鈕
        }
    }


    // 下一題Button
    @IBAction func nextQuestionButtonPressed(_ sender: UIButton) {
        // 檢查是否超出問題範圍
        if index < currentQuestions.count - 1 {

            index = index + 1                                    // 增加 index 值
            setupQuestion()                                      // 題目相關 function

        }
        // 停止音效
        soundPlayer.pause()
    }


    // 重新開始Button
    @IBAction func restartGameButtonPressed(_ sender: UIButton) {

        questions.shuffle()                                     // 隨機打亂所有問題的順序
        currentQuestions = Array(questions.prefix(10))          // 只取前10題（洗牌後）

        index = 0                                               // 重置索引值
        setupQuestion()                                         // 題目相關 function

        score = 0                                               // 分數重置
        scoreLabel.text = "目前得分： 0 分"                       // 計分欄位重置

        questionContentLabel.isHidden = false                   // 因為最後一題會隱藏 題目欄 ，重新開始後，題目顯示
        scoreResultLabel.text = ""                              // 清空評分結果內容
        scoreResultLabel.isHidden = true                        // 重新開始後，會將評分欄給隱藏，以便題目欄可以正常顯示
        restartButton.isHidden = true                           // 重新開始後，重置按鈕隱藏
        soundPlayer.pause()                                     // 停止音效

    }



    // 題目設置相關（問題、選項）、 nextButton隱藏、題目提示
    func setupQuestion() {

        // 更新題目內容
        questionContentLabel.text = currentQuestions[index].questionText

        // 更新選項按鈕的標題，顯示當前文字 (問題的選項數量)，根據當前問題的選項數量，來設定選項按鈕的標題
        for i in 0..<currentQuestions[index].options.count {
            optionButtons[i].setTitle(currentQuestions[index].options[i], for: .normal)
        }

        // 啟用所有選項按鈕，準備開始新的一題。
        for button in optionButtons {
            button.isEnabled = true
        }

        nextButton.isHidden = true                                                // 隱藏nextbutton
        titleNumberLabel.text = "第\(index+1)/\(currentQuestions.count)題"         // 當前第幾題
        answerResultLabel.text = "答題結果"                                        // 更新 選項結果提示
    }



    // 取得評分標準
    func getScoreResultText() {

        let result: String                                      // 根據分數設置不同的結果
        if score < 30 {
            result = "資質駑鈍！再回去翻小說吧！"
        } else if score < 50 {
            result = "資質平庸！梁發是你！？"
        } else if score < 80 {
            result = "少林寺歡迎你！"
        } else {
            result = "你有吃記憶吐司嗎！？"
        }
        scoreResultLabel.text = "最終成績為：\(score) 分" + "\n" + result           // 是最後一題，顯示 評分結果
        scoreResultLabel.isHidden = false                                        // 是最後一題，顯示 評分欄
    }


    // 答對音效
    func correctSound() {
        // 答對音效
        let fileUrl = Bundle.main.url(forResource: "correct answer", withExtension: "mp3")!
        let playerItem = AVPlayerItem(url: fileUrl)
        soundPlayer.replaceCurrentItem(with: playerItem)
        soundPlayer.rate = 0.5
        soundPlayer.play()
    }


    // 答錯音效
    func wrongSound() {
        // 答錯音效
        let fileUrl = Bundle.main.url(forResource: "wrong answer", withExtension: "mp3")!
        let playerItem = AVPlayerItem(url: fileUrl)
        soundPlayer.replaceCurrentItem(with: playerItem)
        soundPlayer.play()
    }


    // 問題列表，包括問題文本，選項，和正確答案。
    func initQuestions() {
        let question1 = MultipleChoiceQuestion(questionText: "何人曾擔任過華山派掌門？", options: ["岳不群", "梁發", "歸辛樹"], correctAnswerText: "岳不群")
        questions.append(question1)
        let question2 = MultipleChoiceQuestion(questionText: "周伯通被黃藥師囚於桃花島多少年？", options: ["十年", "十五年","二十年"], correctAnswerText: "十五年")
        questions.append(question2)
        let question3 = MultipleChoiceQuestion(questionText: "薛慕華的外號為何？", options: ["蝶谷醫仙", "殺人名醫", "閻王敵"], correctAnswerText: "閻王敵")
        questions.append(question3)
        let question4 = MultipleChoiceQuestion(questionText: "哪一個不是喬裝易容後的假名？", options: ["李延宗", "段天德", "莊聚德"], correctAnswerText: "段天德")
        questions.append(question4)
        let question5 = MultipleChoiceQuestion(questionText: "誰將韋小寶在天地會中的職務與行蹤告訴康熙？", options: ["徐天川", "風際中", "錢老本"], correctAnswerText: "風際中")
        questions.append(question5)
        let question6 = MultipleChoiceQuestion(questionText: "包不同命喪何人之手？", options: ["段延慶", "蕭遠山", "慕容復"], correctAnswerText: "慕容復")
        questions.append(question6)
        let question7 = MultipleChoiceQuestion(questionText: "何者由於達摩堂首座被寺中火工頭陀擊斃，一怒之下遠走西域，開創了西域少林一派？", options: ["苦慧禪師", "苦智禪師", "剛相禪師"], correctAnswerText: "苦慧禪師")
        questions.append(question7)
        let question8 = MultipleChoiceQuestion(questionText: "「玉女劍」共有幾式？", options: ["二十式", "十八式", "十九式"], correctAnswerText: "十九式")
        questions.append(question8)
        let question9 = MultipleChoiceQuestion(questionText: "胡斐為何人的後代？", options: ["雪山飛狐", "飛天狐狸", "黑沼靈狐"], correctAnswerText: "飛天狐狸")
        questions.append(question9)
        let question10 = MultipleChoiceQuestion(questionText: "嵩山派中，何人號稱「大嵩陽手」？", options: ["費彬", "陸柏", "丁勉"], correctAnswerText: "費彬")
        questions.append(question10)
        let question11 = MultipleChoiceQuestion(questionText: "若去俠客島，最好懂得誰的詩？", options: ["李白", "杜甫", "王維"], correctAnswerText: "李白")
        questions.append(question11)
        let question12 = MultipleChoiceQuestion(questionText: "馮錫範將被韋小寶釘在棺中的鄭克塽救出時，擊斃了天地會的誰", options: ["關安基", "風際中", "陸高軒"], correctAnswerText: "關安基")
        questions.append(question12)
        let question13 = MultipleChoiceQuestion(questionText: "玄冥二老的弱點為何？", options: ["鹿好酒、鶴好色", "鹿好賭、鶴好色", "鹿好色、鶴好酒"], correctAnswerText: "鹿好色、鶴好酒")
        questions.append(question13)
        let question14 = MultipleChoiceQuestion(questionText: "華山派的劍宗、氣宗之爭，據說因為何書？", options: ["紫霞神功", "辟邪劍法", "葵花寶典"], correctAnswerText: "葵花寶典")
        questions.append(question14)
        let question15 = MultipleChoiceQuestion(questionText: "倚天劍和屠龍刀由何種兵器鑄成？", options: ["金蛇劍", "碧血劍", "玄鐵劍"], correctAnswerText: "玄鐵劍")
        questions.append(question15)
        let question16 = MultipleChoiceQuestion(questionText: "任我行在少林寺三戰中被何人擊敗？", options: ["左冷禪", "方證大師", "岳不群"], correctAnswerText: "左冷禪")
        questions.append(question16)
        let question17 = MultipleChoiceQuestion(questionText: "下列「兇手」與「被害人」的敘述，何項錯誤？", options: ["洪凌波死於李莫愁足下", "刀白鳳被慕容復以長劍刺死", "譚處端命喪歐陽鋒之手"], correctAnswerText: "刀白鳳被慕容復以長劍刺死")
        questions.append(question17)
        let question18 = MultipleChoiceQuestion(questionText: "五毒教三寶之一的「金蛇錐」共有幾枚？", options: ["二十四枚", "十二枚", "三十二枚"], correctAnswerText: "二十四枚")
        questions.append(question18)
        let question19 = MultipleChoiceQuestion(questionText: "何人未曾傳授過郭靖武藝？", options: ["周伯通", "洪七公", "張阿生"], correctAnswerText: "張阿生")
        questions.append(question19)
        let question20 = MultipleChoiceQuestion(questionText: "余魚同剃度出家後，法名為？", options: ["空色", "無色", "無止"], correctAnswerText: "空色")
        questions.append(question20)
        let question21 = MultipleChoiceQuestion(questionText: "「為人不識 ~~~，就稱英雄也枉然。」空格中應填：", options: ["于萬亭", "袁承志", "陳近南"], correctAnswerText: "陳近南")
        questions.append(question21)
        let question22 = MultipleChoiceQuestion(questionText: "趙敏贈予張無忌的珠花中，藏有何種毒藥的解救藥方？", options: ["十香軟筋散", "金蠶蠱毒", "七蟲七花膏"], correctAnswerText: "七蟲七花膏")
        questions.append(question22)
        let question23 = MultipleChoiceQuestion(questionText: "何人將天山童姥由飄緲峰靈鷲宮中擒下山來？", options: ["烏老大", "區島主", "安洞主"], correctAnswerText: "烏老大")
        questions.append(question23)
        let question24 = MultipleChoiceQuestion(questionText: "史婆婆收石破天入門後，為他取名為：", options: ["史千刀", "史萬刀", "史億刀"], correctAnswerText: "史億刀")
        questions.append(question24)
        let question25 = MultipleChoiceQuestion(questionText: "何人不曾在「珍瓏棋局」上下棋？", options: ["段譽", "丁春秋", "鳩摩智"], correctAnswerText: "丁春秋")
        questions.append(question25)
        let question26 = MultipleChoiceQuestion(questionText: "下列少林寺高僧中，何者是蕭峰的授業恩師？", options: ["玄生大師", "玄苦大師", "玄寂大師"], correctAnswerText: "玄苦大師")
        questions.append(question26)
        let question27 = MultipleChoiceQuestion(questionText: "「黯然銷魂掌」中，哪一招是由《九陰真經》的「懾心大法」變化而來？", options: ["呆若木雞", "六神不安", "面無人色"], correctAnswerText: "面無人色")
        questions.append(question27)
        let question28 = MultipleChoiceQuestion(questionText: "俠客島上的臘八粥為什麼顏色？", options: ["綠色", "紅色", "黃色"], correctAnswerText: "綠色")
        questions.append(question28)
        let question29 = MultipleChoiceQuestion(questionText: "「九陰真經」為何人所著？", options: ["黃真", "黃可", "黃裳"], correctAnswerText: "黃裳")
        questions.append(question29)
        let question30 = MultipleChoiceQuestion(questionText: "勞德諾與岳靈珊於福州喬裝賣酒時，自稱何姓？", options: ["薛", "董", "薩"], correctAnswerText: "薩")
        questions.append(question30)
    }
}



//import UIKit
//
//class ViewController: UIViewController {
//
//    // 當前第幾題
//    @IBOutlet weak var titleNumberLabel: UILabel!
//    // 題目內容
//    @IBOutlet weak var questionContentLabel: UILabel!
//    // 選項結果提示
//    @IBOutlet weak var answerResultLabel: UILabel!
//    // 分數
//    @IBOutlet weak var scoreLabel: UILabel!
//    // 結果顯示
//    @IBOutlet weak var scoreResultLabel: UILabel!
//
//    // 三個選項的 UIButton 陣列
//    @IBOutlet var optionButtons: [UIButton]!
//    // 下一題
//    @IBOutlet weak var nextButton: UIButton!
//    // 重新開始Button
//    @IBOutlet weak var restartButton: UIButton!
//
//    // 用於存儲題目
//    var questions = [MultipleChoiceQuestion]()
//
//    // 用來儲存會顯示出來的題目
//    var currentQuestions = [MultipleChoiceQuestion]()
//
//    // 索引選擇題目順序
//    var index = 0
//
//    // 分數追蹤 (當答對十可以加分）
//    var score = 0
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let question1 = MultipleChoiceQuestion(questionText: "何人曾擔任過華山派掌門？", options: ["岳不群", "梁發", "歸辛樹"], correctAnswerText: "岳不群")
//        questions.append(question1)
//        let question2 = MultipleChoiceQuestion(questionText: "周伯通被黃藥師囚於桃花島多少年？", options: ["十年", "十五年","二十年"], correctAnswerText: "十五年")
//        questions.append(question2)
//        let question3 = MultipleChoiceQuestion(questionText: "薛慕華的外號為何？", options: ["蝶谷醫仙", "殺人名醫", "閻王敵"], correctAnswerText: "閻王敵")
//        questions.append(question3)
//        let question4 = MultipleChoiceQuestion(questionText: "哪一個不是喬裝易容後的假名？", options: ["李延宗", "段天德", "莊聚德"], correctAnswerText: "段天德")
//        questions.append(question4)
//        let question5 = MultipleChoiceQuestion(questionText: "誰將韋小寶在天地會中的職務與行蹤告訴康熙？", options: ["徐天川", "風際中", "錢老本"], correctAnswerText: "風際中")
//        questions.append(question5)
//        let question6 = MultipleChoiceQuestion(questionText: "包不同命喪何人之手？", options: ["段延慶", "蕭遠山", "慕容復"], correctAnswerText: "慕容復")
//        questions.append(question6)
//        let question7 = MultipleChoiceQuestion(questionText: "何者由於達摩堂首座被寺中火工頭陀擊斃，一怒之下遠走西域，開創了西域少林一派？", options: ["苦慧禪師", "苦智禪師", "剛相禪師"], correctAnswerText: "苦慧禪師")
//        questions.append(question7)
//        let question8 = MultipleChoiceQuestion(questionText: "「玉女劍」共有幾式？", options: ["二十式", "十八式", "十九式"], correctAnswerText: "十九式")
//        questions.append(question8)
//        let question9 = MultipleChoiceQuestion(questionText: "胡斐為何人的後代？", options: ["雪山飛狐", "飛天狐狸", "黑沼靈狐"], correctAnswerText: "飛天狐狸")
//        questions.append(question9)
//        let question10 = MultipleChoiceQuestion(questionText: "嵩山派中，何人號稱「大嵩陽手」？", options: ["費彬", "陸柏", "丁勉"], correctAnswerText: "費彬")
//        questions.append(question10)
//        let question11 = MultipleChoiceQuestion(questionText: "若去俠客島，最好懂得誰的詩？", options: ["李白", "杜甫", "王維"], correctAnswerText: "李白")
//        questions.append(question11)
//
//        // 預設：重新開始Button隱藏，到最後一題，才會顯示。
//        restartButton.isHidden = true
//        // 預設：nextButton先隱藏，必須做出選擇才會顯示。
//        nextButton.isHidden = true
//        // 預設：隱藏得分結果顯示
//        scoreResultLabel.isHidden = true
//
//        // 調用重新開始函數來進行題目洗牌和畫面設定
//        restartGameButtonPressed(restartButton)
//    }
//
//
//
//    // 正確答案
//    @IBAction func correctAnswerButton(_ sender: UIButton) {
//
//        let answer = currentQuestions[index].correctAnswerText     // 宣告一個正確答案的陣列
//
//        // 判斷是否正確答案
//        if sender.title(for: .normal) == answer {
//            answerResultLabel.text = "你答對了！"                   // 正確：選項結果提示
//
//            score = score + 10                                     // 答對加10分
//            scoreLabel.text = "目前得分： \(score) 分"
//
//        } else {
//            answerResultLabel.text = "不要瞎猜好嗎！"                // 錯誤：選項結果提示
//        }
//
//        // 禁用其他選項的交互性
//        for button in optionButtons {
//            button.isEnabled = false
//        }
//
//        // 檢查是否為最後一題
//        if index == currentQuestions.count - 1 {
//            nextButton.isHidden = true                              // 是最後一題，隱藏nextButton按鈕
//            restartButton.isHidden = false                          // 是最後一題，顯示restartButton按鈕
//            questionContentLabel.isHidden = true
//
//            // 根據分數設置不同的結果
//            let result: String
//            if score < 30 {
//                result = "資質駑鈍！再回去翻小說吧！"
//            } else if score < 50 {
//                result = "資質平庸！梁發是你！？"
//            } else if score < 80 {
//                result = "少林寺歡迎你！"
//            } else {
//                result = "你有吃記憶吐司嗎！？"
//            }
//
//            scoreResultLabel.text = "最終成績為：\(score) 分" + "\n" + result           // 顯示評分結果
//            scoreResultLabel.isHidden = false
//
//        } else {
//            nextButton.isHidden = false                             // 不是最後一題，顯示nextButton按鈕
//        }
//    }
//
//
//    // 下一題Button
//    @IBAction func nextQuestionButtonPressed(_ sender: UIButton) {
//        // 檢查是否超出問題範圍
//        if index < currentQuestions.count - 1 {
//
//            index = index + 1                                         // 增加 index 值
//
//            // 更新題目內容
//            questionContentLabel.text = currentQuestions[index].questionText
//
//            // 更新選項按鈕的標題，顯示當前文字 (問題的選項數量)，根據當前問題的選項數量，來設定選項按鈕的標題
//            for i in 0..<currentQuestions[index].options.count {
//                optionButtons[i].setTitle(currentQuestions[index].options[i], for: .normal)
//            }
//
//            // 啟用選項按鈕的交互性
//            for button in optionButtons {
//                button.isEnabled = true
//            }
//
//            // 隱藏nextbutton
//            nextButton.isHidden = true
//
//            // 當前第幾題
//            titleNumberLabel.text = "第\(index+1)/\(currentQuestions.count)題"
//
//            // 更新 選項結果提示
//            answerResultLabel.text = "答題結果"
//
//        } else {
//            index = currentQuestions.count - 1
//            nextButton.isHidden = true
//
//            // 啟用 重新開始功能
//            restartButton.isHidden = false
//        }
//
//    }
//
//
//    // 重新開始Button
//    @IBAction func restartGameButtonPressed(_ sender: UIButton) {
//
//        // 洗牌
//        questions.shuffle()
//
//        // 只取前10題
//        currentQuestions = Array(questions.prefix(10))
//
//        // 重置索引值
//        index = 0
//
//        // 顯示第一個問題
//        questionContentLabel.text = currentQuestions[index].questionText
//
//        // 問題的選項更新設定
//        for i in 0..<currentQuestions[index].options.count {
//            optionButtons[i].setTitle(currentQuestions[index].options[i], for: .normal)
//        }
//
//        // 當前第幾題
//        titleNumberLabel.text = "第\(index + 1)/\(currentQuestions.count)題"
//        // 答題結果提示
//        answerResultLabel.text = "答題結果"
//
//        // 重置按鈕隱藏
//        restartButton.isHidden = true
//
//        // 啟用選項按鈕的交互性
//        for button in optionButtons {
//            button.isEnabled = true
//        }
//
//        // 分數重置
//        score = 0
//        scoreLabel.text = "目前得分： 0 分"
//
//        // 題目顯示
//        questionContentLabel.isHidden = false
//
//        // 預設：隱藏得分結果顯示
//        scoreResultLabel.text = ""
//        scoreResultLabel.isHidden = true
//
//    }
//
//    func setupQuestion() {
//        // 更新題目內容
//        questionContentLabel.text = currentQuestions[index].questionText
//
//        // 更新選項按鈕的標題，顯示當前文字 (問題的選項數量)，根據當前問題的選項數量，來設定選項按鈕的標題
//        for i in 0..<currentQuestions[index].options.count {
//            optionButtons[i].setTitle(currentQuestions[index].options[i], for: .normal)
//        }
//
//        // 啟用選項按鈕的交互性
//        for button in optionButtons {
//            button.isEnabled = true
//        }
//
//        // 隱藏nextbutton
//        nextButton.isHidden = true
//
//        // 當前第幾題
//        titleNumberLabel.text = "第\(index+1)/\(currentQuestions.count)題"
//
//        // 更新 選項結果提示
//        answerResultLabel.text = "答題結果"
//    }
//
//
//}
