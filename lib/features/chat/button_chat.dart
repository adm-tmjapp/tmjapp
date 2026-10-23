import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'data/ride_chat_api.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen(
      {super.key,
      this.rideId,
      this.driverName = 'Motorista',
      this.driverRating,
      this.driverPhone,
      this.driverPhotoUrl});
  final String? rideId;
  final String driverName;
  final double? driverRating;
  final String? driverPhone;
  final String? driverPhotoUrl;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const _primary = Color(0xFFC82A75);
  final _api = RideChatApi();
  final _input = TextEditingController();
  final _scroll = ScrollController();
  List<RideChatMessage> _messages = const [];
  Timer? _timer;
  bool _loading = true;
  bool _sending = false;
  bool _chatClosed = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final rideId = widget.rideId;
    if (rideId == null || rideId.trim().isEmpty) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = 'Chat disponível após o motorista aceitar a corrida.';
        });
      return;
    }
    try {
      final messages = await _api.list(rideId);
      await _api.markRead(rideId);
      if (!mounted) return;
      setState(() {
        _messages = messages;
        _loading = false;
        _error = null;
      });
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    } catch (error) {
      final message = error.toString().replaceFirst('Exception: ', '');
      if (message.contains('encerrado após o término')) {
        _timer?.cancel();
        if (mounted) {
          setState(() {
            _loading = false;
            _error = message;
            _chatClosed = true;
          });
        }
        return;
      }
      if (mounted && _messages.isEmpty)
        setState(() {
          _loading = false;
          _error = error.toString().replaceFirst('Exception: ', '');
        });
    }
  }

  Future<void> _send([String? quick]) async {
    final rideId = widget.rideId;
    final text = (quick ?? _input.text).trim();
    if (rideId == null || text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final message = await _api.send(rideId, text);
      if (!mounted) return;
      setState(() {
        _messages = [..._messages, message];
        _input.clear();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients)
          _scroll.jumpTo(_scroll.position.maxScrollExtent);
      });
    } catch (error) {
      if (error.toString().contains('encerrado após o término') && mounted) {
        _timer?.cancel();
        setState(() => _chatClosed = true);
      }
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _call() async {
    final phone = widget.driverPhone?.trim();
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Telefone do motorista indisponível.')));
      return;
    }
    await launchUrl(Uri(scheme: 'tel', path: phone));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Chat com motorista'), actions: [
          IconButton(onPressed: _call, icon: const Icon(Icons.phone_outlined))
        ]),
        body: Column(children: [
          _Header(
              name: widget.driverName,
              rating: widget.driverRating,
              photoUrl: widget.driverPhotoUrl),
          Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: _primary))
                  : _error != null && _messages.isEmpty
                      ? Center(
                          child: Padding(
                              padding: const EdgeInsets.all(24),
                              child:
                                  Text(_error!, textAlign: TextAlign.center)))
                      : ListView.builder(
                          controller: _scroll,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (_, i) =>
                              _Bubble(message: _messages[i]))),
          _Input(
              controller: _input,
              sending: _sending || _chatClosed,
              onSend: _send),
        ]),
      );
}

class _Header extends StatelessWidget {
  const _Header({required this.name, this.rating, this.photoUrl});
  final String name;
  final double? rating;
  final String? photoUrl;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      color: Colors.white,
      child: Row(children: [
        CircleAvatar(
            radius: 25,
            backgroundImage: (photoUrl?.isNotEmpty ?? false)
                ? NetworkImage(photoUrl!)
                : null,
            child:
                (photoUrl?.isEmpty ?? true) ? const Icon(Icons.person) : null),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          Text(
              'Motorista${rating == null ? '' : ' • ${rating!.toStringAsFixed(1)} ⭐'}',
              style: TextStyle(color: Colors.grey[600]))
        ])
      ]));
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final RideChatMessage message;
  @override
  Widget build(BuildContext context) => Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          constraints: const BoxConstraints(maxWidth: 310),
          decoration: BoxDecoration(
              color: message.isMine ? const Color(0xFFC82A75) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Color(0x11000000), blurRadius: 4)
              ]),
          child: Text(message.content,
              style: TextStyle(
                  color:
                      message.isMine ? Colors.white : const Color(0xFF1E212B),
                  height: 1.25))));
}

class _Input extends StatelessWidget {
  const _Input(
      {required this.controller, required this.sending, required this.onSend});
  final TextEditingController controller;
  final bool sending;
  final Future<void> Function([String?]) onSend;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Estou no local', 'Onde você está?', 'Cheguei']
                  .map((text) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(text),
                          onPressed: sending ? null : () => onSend(text),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Digite uma mensagem',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(22)),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Color(0xFFF3F4F6),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            IconButton(
              onPressed: sending ? null : () => onSend(),
              icon: const Icon(Icons.send_rounded, color: Color(0xFFC82A75)),
            ),
          ]),
        ]),
      ),
    );
  }
}
