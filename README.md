Elastic Machine Controller Flutter App
This Flutter app is designed to control an Elastic Machine Controller (EMC) based on real-time production data. It connects to a backend production system, retrieves real-time data, and allows operators to control machine settings, view production status, and make adjustments directly from their mobile devices.

Features
Real-Time Production Monitoring: Fetch and display live data from the production system.
Machine Control: Start, stop, and adjust machine settings through an intuitive interface.
Analytics & Reports: Generate and view reports based on historical production data.
User Authentication: Secure login system to ensure only authorized users can access machine controls.
Screenshots
Here are some screenshots to demonstrate the app's functionality:


Installation
Prerequisites
Flutter SDK: Ensure you have Flutter installed. Follow the instructions here to set up Flutter.
Backend API: This app requires a backend API to fetch production data and control the machine. Ensure you have access to the API or a local instance running.
Steps
Clone the repository:

bash
Copy code
git clone https://github.com/plabon5150/IOTElasticMachineOpApp.git
cd elastic-machine-controller
Install dependencies:

bash
Copy code
flutter pub get
Set up environment variables:

Create a .env file in the root of the project and add your API base URL and authentication details as needed:

env
Copy code
API_BASE_URL=https://your-api-url.com
API_KEY=your_api_key
Run the app:

bash
Copy code
flutter run
The app should now launch in your connected emulator or physical device.

Usage
Login: Open the app and log in using RFID. Only authorized users will be able to access machine controls.

View Machine Status: Navigate to the "Status" section to view real-time data from the machine.

Control Machine: Access the "Control" panel to start, stop, or modify machine settings based on real-time requirements.

Analytics and Reports: Generate reports from the historical production data for insights into machine performance and efficiency.

MODBUS TEST-SY500,SY9000



You can download and view the demo video [here](./screenshots/welcome.mp4).

License
This project is licensed under the MIT License - see the LICENSE file for details.

