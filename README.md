# MindEngage Mobile

## Introduction
MindEngage Mobile is the front-end application of the MindEngage educational platform. Built with Flutter, it offers a responsive and engaging learning experience across all mobile devices, utilizing AI-driven quizzes and Socratic learning methods to enhance user engagement and educational depth.

## Features
- Interactive quizzes powered by NVIDIA's NIM Generative AI
- Socratic method integrations for deeper learning
- Dynamic content delivery tailored to individual learning styles
- Real-time feedback and adaptive learning paths
- Secure session management

## Getting Started

### Prerequisites
- Flutter (Latest Stable Version)
- Dart SDK
- An IDE (Android Studio/VS Code)
- Git

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/mind-engage/mind-engage-mobile.git
   ```
2. Navigate to the project directory:
   ```bash
   cd mind-engage-mobile
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. create a file dotenv that contains endpoint for backend
   ```
   MIND_ENGAGE_API=<backend endpoint>
   ```
5. Run the app:
   ```bash
   flutter run
   ```

## Usage
To start the app, ensure you have an emulator running or a mobile device connected to your development environment. After starting the app, follow the on-screen instructions to navigate through the educational content.

## Contributing
Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License
Distributed under the MIT License. See `LICENSE` for more information.

## Contact
Project Link: [https://github.com/mind-engage/mind-engage-mobile](https://github.com/mind-engage/mind-engage-mobile)

## Acknowledgments
- NVIDIA NIM Generative AI inference platform
- LangChain/LangGraph for knowledge query pipelines
- All contributors and developers who have helped shape this project.