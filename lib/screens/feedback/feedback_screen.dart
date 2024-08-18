import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:user_app/components/mood_icon_data.dart';
import 'package:user_app/enums/rating_enums.dart';
import 'package:user_app/enums/user_enums.dart';
import 'package:user_app/models/neta_rating.dart';
import 'package:user_app/models/user.dart';
import 'package:user_app/screens/login/login_screen.dart';
import 'package:user_app/services/neta_rating_service.dart';
import 'package:user_app/services/preferences_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  PolmitraUser? _loginUser; // Stores the current logged-in user
  NetaRatingService? _netaRatingService; // Service to handle Neta ratings
  final TextEditingController _reasonController = TextEditingController(); // Controller for the reason input
  RatingEnum? _selectedMood; // Stores the selected mood
  List<NetaRating> _karyakartaRatings = []; // List of ratings by karyakarta
  List<NetaRating> _netaRatings = []; // List of ratings for neta

  @override
  void initState() {
    super.initState();
    _loadUserDetails(); // Load user details when the widget is initialized
    _netaRatingService = Provider.of<NetaRatingService>(context, listen: false); // Initialize the NetaRatingService
  }

  @override
  void dispose() {
    _reasonController.dispose(); // Dispose of the text controller when the widget is disposed
    super.dispose();
  }

  // Ensures the user is logged in before performing actions
  bool _ensureUserLoggedIn() {
    if (_loginUser == null) {
      _promptLogin(); // If not logged in, prompt the user to log in
      return false;
    }
    return true;
  }

  // Prompts the user to log in if they are not logged in
  void _promptLogin() {
    Fluttertoast.showToast(
      msg: "Please login to continue.",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
    // Navigate to the login screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // Loads the user details from the preferences service and fetches ratings based on role
  void _loadUserDetails() async {
    final user = await PrefsService.getUser();
    if (user == null) {
      _promptLogin(); // If user details are not found, prompt login
    } else {
      setState(() {
        _loginUser = user; // Set the logged-in user
      });

      // Fetch ratings based on user role
      if (_loginUser?.role == UserRole.karyakarta.toString()) {
        _loadKaryakartaRatings();
      } else if (_loginUser?.role == UserRole.neta.toString()) {
        _loadNetaRatings();
      }
    }
  }

  // Load ratings made by karyakarta
  void _loadKaryakartaRatings() async {
    final ratings = await _netaRatingService?.findAllRatingsByKaryakarta(_loginUser!.uid);
    setState(() {
      _karyakartaRatings = ratings ?? [];
    });
  }

  // Load all ratings for the neta
  void _loadNetaRatings() async {
    final ratings = await _netaRatingService?.getAllRatingsForNeta(_loginUser!.uid);
    setState(() {
      _netaRatings = ratings ?? [];
    });
  }

  // Handles the submission of the selected mood and reason
  void _submitRating() async {
    if (!_ensureUserLoggedIn()) return;

    if (_selectedMood == null) {
      Fluttertoast.showToast(
        msg: "Please select a mood before submitting.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    if (_selectedMood == RatingEnum.OTHER && _reasonController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please provide a reason for selecting 'Other'.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    final NetaRating netaRating = NetaRating(
      netaId: _loginUser!.netaId,
      karyakartaId: _loginUser!.uid,
      rating: _selectedMood.toString(),
      reason: _reasonController.text,
      createAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      karyakarta: _loginUser!,
    );

    await _netaRatingService?.addNetaRatings(netaRating);
    _clearInputs(); // Clear inputs after submission
    Fluttertoast.showToast(
      msg: "Rating submitted successfully!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    // Reload ratings after submission
    if (_loginUser?.role == UserRole.karyakarta.toString()) {
      _loadKaryakartaRatings();
    } else if (_loginUser?.role == UserRole.neta.toString()) {
      _loadNetaRatings();
    }
  }

  // Clears the selected mood and reason input after submitting
  void _clearInputs() {
    setState(() {
      _selectedMood = null;
      _reasonController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator until the user details are loaded
    if (_loginUser == null) return const Center(child: CircularProgressIndicator());

    // Determine the role of the user and load the appropriate UI
    final role = UserRole.values
        .firstWhere((role) => role.toString() == _loginUser?.role.toString(), orElse: () => UserRole.karyakarta);
    switch (role) {
      case UserRole.karyakarta:
        return _getKaryakartaUi();
      case UserRole.neta:
        return _getNetaUi();
      case UserRole.superadmin:
        return _getKaryakartaUi();
    }
  }

  // UI for karyakarta role
  Widget _getKaryakartaUi() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate your Neta',
              style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildMoodIcons(),
            ),
            const SizedBox(height: 16.0),
            // Always display the reason text input below the icons
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (Optional)',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            // Submit button to send the selected mood and reason
            ElevatedButton(
              onPressed: _submitRating,
              child: const Text('Submit Rating'),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Your Ratings:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: _karyakartaRatings.length,
                itemBuilder: (context, index) {
                  final rating = _karyakartaRatings[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Mood: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: rating.rating.split('.').last,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Reason: ${rating.reason ?? 'No reason provided'}',
                            style: const TextStyle(fontSize: 14.0),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Date: ${rating.createAt?.toDate().toLocal().toString() ?? ''}',
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI for neta role
  Widget _getNetaUi() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All Ratings for You:',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _netaRatings.length,
                itemBuilder: (context, index) {
                  final rating = _netaRatings[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Mood: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: rating.rating.split('.').last,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Reason: ${rating.reason ?? 'No reason provided'}',
                            style: const TextStyle(fontSize: 14.0),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Date: ${rating.createAt?.toDate().toLocal().toString() ?? ''}',
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the mood icons with their respective selections
  List<Widget> _buildMoodIcons() {
    return [
      _buildMoodIcon(RatingEnum.SASTISFIED, Icons.thumb_up, 'Satisfied'),
      _buildMoodIcon(RatingEnum.NON_SASTISFIED, Icons.thumb_down, 'Non-Satisfied'),
      _buildMoodIcon(RatingEnum.MAYBE, Icons.help_outline, 'Maybe'),
      _buildMoodIcon(RatingEnum.OTHER, Icons.edit, 'Other'),
    ];
  }

  // Helper method to build the UI for each mood icon with a border for the selected one
  Widget _buildMoodIcon(RatingEnum mood, IconData icon, String label) {
    final bool isSelected = _selectedMood == mood;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = mood;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: Colors.blue, width: 3.0) // Add a blue border if selected
              : Border.all(color: Colors.transparent, width: 3.0), // No border if not selected
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey, // Highlight selected icon
              size: 40.0,
            ),
            const SizedBox(height: 8.0),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.black, // Highlight selected label
              ),
            ),
          ],
        ),
      ),
    );
  }
}
