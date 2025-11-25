# 🎮 QuickBurstTV  
A Multiplayer Trivia Party Game for tvOS 17+

QuickBurstTV is an interactive, fast-paced trivia game designed for the Apple TV platform.  
Players take turns answering questions, earn points for correct answers, and battle for the top spot on the scoreboard — all from the comfort of the TV screen.

Built using **SwiftUI**, **tvOS 17**, and **Apple's Focus Engine**, the app delivers smooth navigation using the Apple TV Remote or the tvOS Simulator keyboard.

---

## 🚀 Features

### 🧑‍🤝‍🧑 Multiplayer Game Flow
- Add multiple players in the lobby
- Player names stored for the session
- Automatic turn-based answering system
- Scoreboard at the end showing winners

### 🧠 Trivia Question System
- Built-in sample question set
- Randomized question ordering
- Correct answer highlighting after each round

### 🎯 Fully tvOS-Friendly UI
- Focusable buttons for remote navigation  
- Custom focus sections for smooth movement  
- Controller and keyboard navigation supported  
- Optimized for living-room usage

### 🖥️ Clean, Modern SwiftUI Interface
- Gradient backgrounds  
- Large readable TV typography  
- Animated and interactive buttons  
- Rounded card-style components

---

## 📦 Project Structure

```shell
QuickBurstTV/
│
├── ContentView.swift # All screens: Lobby, Question, Scoreboard
├── GameViewModel.swift # Game logic, state management
├── Models.swift # Data models: Question, Player, GamePhase
└── QuickBurstTVApp.swift # App entry point
```


---

## 🧩 Technical Highlights

- **SwiftUI (tvOS)**  
  Fully declarative UI designed for Apple TV screens.

- **Focus Engine Integration**  
  `.focusable(true)` and `.focusSection()` used for precise navigation.

- **MVVM Architecture**  
  - `GameViewModel` manages all logic and game state  
  - Views are fully reactive via `@EnvironmentObject`

- **Randomized Question Flow**  
  Ensures replayability with shuffled question order.

---

## 🕹️ Controls (Simulator & Real Apple TV)

### Keyboard (tvOS Simulator)
- **↑ ↓ ← →** — Move focus  
- **Enter / Return** — Select  
- **Backspace** — Go back (when applicable)  
- **Fn + ←** — Home screen  

### Apple TV Remote
- Touch surface / D-Pad for navigation  
- Select button to choose answers/items  

---

## ▶️ Running the App

### Requirements
- Xcode 15 or later  
- tvOS 17 SDK  
- Apple TV 4K (optional)  

### Steps
1. Clone or download the project  
2. Open `QuickBurstTV.xcodeproj` in Xcode  
3. Set the run target to **Apple TV 4K (tvOS 17+)**  
4. Build & run  
5. Use arrow keys or the on-screen remote to play  

---

## 🔧 How to Add More Questions
Open **`Models.swift`** → find:

```swift
static let sampleQuestions: [Question] = [
    Question(...),
    Question(...)
]

// Add your new question like:
Question(
    id: UUID(),
    text: "Your question here...",
    options: ["A", "B", "C", "D"],
    correctIndex: 1
)

```

# 🛠️ Future Enhancements (Optional for Assignment)
These improvements can expand your Part B marks:
- iPhone as controller (MultipeerConnectivity)
- Timers & power-ups
- Animations and sound effects
- More question packs (JSON loading)
- Profile pictures or icons for players
- Game center achievements

# 📝 Author
```
Kisura W. S. P
BSc (Hons) in Information Technology Specializing in Interactive Media — SE4041 Mobile Application Development & Design (2025)
```

# 📄 License
```
This project is intended for academic and portfolio use.
```
