import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  final String appDescription =
      'Elecxa App\n\nVersion 1.0.0\n\nElecxa connects local electronics stores and customers, providing an efficient platform to browse products, communicate, and manage purchases seamlessly. '
      'Built with Flutter and Firebase, Elecxa addresses the need for streamlined connections between store owners and customers by enabling real-time messaging, product management, and customer assistance in one convenient app.';

  final String developerDescription =
      'I am a Computer Science and Business Systems student at REC, Chennai, with a deep passion for technology and aspirations to become an ethical hacker. '
      'I have continuously challenged myself in cybersecurity, networking, and programming, reflecting my dedication in multiple achievements and certifications. '
      'As an avid learner and a committed cybersecurity enthusiast, I aim to make a meaningful impact in the technology world.';

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // About App
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'About Elecxa',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                appDescription,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
              ),
            ),
            SizedBox(height: 30),

            // About Developer Title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'About the Developer',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            SizedBox(height: 10),

            // Developer Profile Photo
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/dev.jpg'), // Adjust path
              backgroundColor: Colors.transparent,
            ),
            SizedBox(height: 15),

            // Developer Name
            Text(
              'Rahul Babu M P',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),

            // About Developer
            Text(
              developerDescription,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),

            // Contact Information
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Contact',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            SizedBox(height: 10),

            // Contact Details with Icons
            Row(
              children: [
                Icon(Icons.email, color: Colors.blue),
                SizedBox(width: 10),
                Text(
                  'rahulbabuoffl@gmail.com',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.blue),
                SizedBox(width: 10),
                Text(
                  '+91 9514803391',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.web, color: Colors.blue),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _launchURL('https://rahulthewhitehat.github.io'),
                  child: Text(
                    'rahulthewhitehat.github.io',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.web, color: Colors.blue),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _launchURL('https://linktr.ee/rahulthewhitehat'),
                  child: Text(
                    'linktr.ee/rahulthewhitehat',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
