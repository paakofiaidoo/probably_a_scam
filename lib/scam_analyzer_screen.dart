import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ScamAnalyzerScreen extends StatefulWidget {
  const ScamAnalyzerScreen({super.key});

  @override
  State<ScamAnalyzerScreen> createState() => _ScamAnalyzerScreenState();
}

class _ScamAnalyzerScreenState extends State<ScamAnalyzerScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  String _rankingOutput = "Ranking: N/A";
  String _explanationOutput =
      "Explanation: Submit text or a URL to see results.";
  bool _isLoading = false;

  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    // Replace 'YOUR_API_KEY' with your actual API key
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: const String.fromEnvironment('GOOGLE_API_KEY'),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _analyzeContent() async {
    setState(() {
      _isLoading = true;
      _rankingOutput = "Ranking: Analyzing...";
      _explanationOutput = "Explanation: Please wait.";
    });

    final String input = _textController.text.isNotEmpty
        ? _textController.text
        : _urlController.text;
    final String prompt;

    if (input.isEmpty) {
      setState(() {
        _rankingOutput = "Ranking: N/A";
        _explanationOutput = "Explanation: Please enter text or a URL.";
        _isLoading = false;
      });
      return;
    }

    if (_textController.text.isNotEmpty) {
      prompt =
          "Analyze the following text for scam indicators and provide a ranking (\"Definitely a Scam\", \"Probably a Scam (Be Careful)\", \"Not a Scam\") and a detailed explanation. Text: $input";
    } else {
      prompt =
          "Analyze the content of the following URL for scam indicators and provide a ranking (\"Definitely a Scam\", \"Probably a Scam (Be Careful)\", \"Not a Scam\") and a detailed explanation. URL: $input";
    }

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final generatedText = response.text;

      if (generatedText != null) {
        final lines = generatedText.split('\n');
        if (lines.length >= 2) {
          setState(() {
            _rankingOutput = "Ranking: ${lines[0]}";
            _explanationOutput =
                "Explanation: ${lines.skip(1).join('\n')}";
          });
        } else {
          setState(() {
            _rankingOutput = "Ranking: Analysis Failed";
            _explanationOutput =
                "Explanation: Could not parse API response.";
          });
        }
      } else {
        setState(() {
          _rankingOutput = "Ranking: Analysis Failed";
          _explanationOutput = "Explanation: Empty API response.";
        });
      }
    } catch (e) {
      setState(() {
        _rankingOutput = "Ranking: Error";
        _explanationOutput =
            "Explanation: An error occurred during analysis. Please try again.";
      });
      print("Gemini API Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _flagAsScam() {
    // Implement logic to record feedback (e.g., update Firestore)
    print("User flagged as scam");
    // updateFeedbackInFirestore(currentSubmissionId, feedback: .scam)
  }

  void _notAScam() {
    // Implement logic to record feedback (e.g., update Firestore)
    print("User flagged as not a scam");
    // updateFeedbackInFirestore(currentSubmissionId, feedback: .notScam)
  }

  void _donate() {
    // Implement logic to open the Paystack donation link
    // This might involve opening a URL in a web view or external browser.
    print("Open donation link");
    // openUrl("YOUR_PAYSTACK_DONATION_LINK")
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scam Analyzer"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Enter Text or URL:"),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: "Paste suspicious text here",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: null,
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        hintText: "Enter suspicious URL here",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _analyzeContent,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text("Analyze"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Analysis Results:"),
                    const SizedBox(height: 8.0),
                    Text(
                      _rankingOutput,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      _explanationOutput,
                      maxLines: null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Is this analysis correct?"),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _flagAsScam,
                            child: const Text("Flag as Scam"),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _notAScam,
                            child: const Text("Not a Scam"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Support Us:"),
                    const SizedBox(height: 8.0),
                    const Text(
                        "If you find this app helpful, please consider donating to support its development."),
                    const SizedBox(height: 8.0),
                    ElevatedButton(
                      onPressed: _donate,
                      child: const Text("Donate via Paystack"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
