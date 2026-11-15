import 'package:flutter/material.dart';

import '../services/ai_trip_planner_service.dart';

class AiTripPlannerScreen extends StatefulWidget {
  const AiTripPlannerScreen({super.key, this.language = 'ar'});

  final String language;

  @override
  State<AiTripPlannerScreen> createState() => _AiTripPlannerScreenState();
}

class _AiTripPlannerScreenState extends State<AiTripPlannerScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final AiTripPlannerService _service;
  final List<_ChatMessage> _messages = [];
  bool _loading = false;

  String _text(String ar, String en, String fr, String es) {
    switch (widget.language) {
      case 'en':
        return en;
      case 'fr':
        return fr;
      case 'es':
        return es;
      default:
        return ar;
    }
  }

  @override
  void initState() {
    super.initState();
    _service = AiTripPlannerService();
    _messages.add(
      _ChatMessage(
        text: _text(
          'مرحباً بك في مرشد SirSir الذكي. اسأل عن الوجهات أو خطط الرحلات أو التنقل داخل المغرب.',
          'Welcome to the SirSir AI guide. Ask about destinations, trip plans or travel around Morocco.',
          'Bienvenue dans le guide IA SirSir. Posez vos questions sur les destinations, les itinéraires ou les déplacements au Maroc.',
          'Bienvenido a la guía IA de SirSir. Pregunta sobre destinos, itinerarios o desplazamientos por Marruecos.',
        ),
        isAssistant: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final question = _controller.text.trim();
    if (question.isEmpty || _loading) return;

    _controller.clear();
    setState(() {
      _messages.add(_ChatMessage(text: question, isAssistant: false));
      _loading = true;
    });
    _scrollToBottom();

    try {
      final reply = await _service.ask(
        question: question,
        language: widget.language,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(text: reply, isAssistant: true));
        _loading = false;
      });
    } on AiTripPlannerException catch (error) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            text: error.message,
            isAssistant: true,
            isError: true,
          ),
        );
        _loading = false;
      });
    } finally {
      if (mounted) _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_text(
          'مرشد SirSir الذكي',
          'SirSir AI Guide',
          'Guide IA SirSir',
          'Guía IA SirSir',
        )),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(14),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_loading && index == _messages.length) {
                  return Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 10),
                          Text(_text(
                            'يفكر المرشد الذكي…',
                            'The guide is thinking…',
                            'Le guide réfléchit…',
                            'La guía está pensando…',
                          )),
                        ],
                      ),
                    ),
                  );
                }
                final message = _messages[index];
                return Align(
                  alignment: message.isAssistant
                      ? AlignmentDirectional.centerStart
                      : AlignmentDirectional.centerEnd,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.86,
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: message.isError
                          ? Colors.red.shade50
                          : message.isAssistant
                              ? Theme.of(context).colorScheme.surfaceContainerHighest
                              : Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SelectableText(
                      message.text,
                      style: TextStyle(
                        height: 1.45,
                        color: message.isError ? Colors.red.shade900 : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Text(
              _text(
                'الإجابات إرشادية؛ تحقق من الأسعار والحجوزات والتنبيهات من المصادر الرسمية.',
                'Answers are informational. Verify prices, bookings and alerts with official sources.',
                'Les réponses sont indicatives. Vérifiez les prix, réservations et alertes auprès des sources officielles.',
                'Las respuestas son orientativas. Verifica precios, reservas y avisos en fuentes oficiales.',
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 2000,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: _text(
                          'اكتب سؤالك عن السفر…',
                          'Ask a travel question…',
                          'Posez une question sur le voyage…',
                          'Escribe tu pregunta de viaje…',
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 52,
                    width: 52,
                    child: IconButton.filled(
                      tooltip: _text('إرسال', 'Send', 'Envoyer', 'Enviar'),
                      onPressed: _loading ? null : _send,
                      icon: const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isAssistant,
    this.isError = false,
  });

  final String text;
  final bool isAssistant;
  final bool isError;
}
