import 'package:flutter/material.dart';

void main() {
  runApp(const TmjApp());
}

class TmjApp extends StatelessWidget {
  const TmjApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'tmj',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFC82A75),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFFC82A75)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1E212B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const ChatScreen(),
    );
  }
}

// --- MODELO DE DADOS ---

class ChatMessage {
  final String text;
  final String senderName;
  final String time;
  final bool isMe;
  final String avatarUrl;

  ChatMessage({
    required this.text,
    required this.senderName,
    required this.time,
    required this.isMe,
    required this.avatarUrl,
  });
}

// --- TELA PRINCIPAL ---

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Color primaryColor = const Color(0xFFC82A75);
  final String driverAvatar =
      'https://i.pravatar.cc/150?img=11'; // Placeholder Motorista
  final String passengerAvatar =
      'https://i.pravatar.cc/150?img=12'; // Placeholder Passageiro

  late List<ChatMessage> messages;

  @override
  void initState() {
    super.initState();
    // Dados mockados baseados no seu layout
    messages = [
      ChatMessage(
        text: 'Olá! Já estou a caminho do local de embarque.',
        senderName: 'João Santos',
        time: '14:02',
        isMe: false,
        avatarUrl: driverAvatar,
      ),
      ChatMessage(
        text: 'Combinado, estou aguardando na calçada.',
        senderName: 'Você',
        time: '14:03',
        isMe: true,
        avatarUrl: passengerAvatar,
      ),
      ChatMessage(
        text: 'Perfeito. Chego em 2 minutos.',
        senderName: 'João Santos',
        time: '14:05',
        isMe: false,
        avatarUrl: driverAvatar,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {}, // Ação de voltar
        ),
        title: const Text('Chat com Motorista'),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined),
            onPressed: () {}, // Ação de ligar
          ),
        ],
      ),
      body: Column(
        children: [
          // Cabeçalho do Motorista
          DriverHeader(
            name: 'João Santos',
            rating: '4.9',
            avatarUrl: driverAvatar,
            primaryColor: primaryColor,
          ),

          // Área do Chat
          Expanded(
            child: Container(
              color: const Color(0xFFF7F7F9), // Fundo cinza bem claro
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return MessageBubble(
                    message: messages[index],
                    primaryColor: primaryColor,
                  );
                },
              ),
            ),
          ),

          // Área de Input e Respostas Rápidas
          ChatInputArea(primaryColor: primaryColor),
        ],
      ),
    );
  }
}

// --- COMPONENTES (WIDGETS) ---

class DriverHeader extends StatelessWidget {
  final String name;
  final String rating;
  final String avatarUrl;
  final Color primaryColor;

  const DriverHeader({
    super.key,
    required this.name,
    required this.rating,
    required this.avatarUrl,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E212B),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, color: primaryColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Motorista • $rating',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Color primaryColor;

  const MessageBubble({
    super.key,
    required this.message,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isMe) _buildAvatar(),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Info do Remetente (Nome • Hora)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6, left: 4, right: 4),
                  child: Text(
                    '${message.senderName} • ${message.time}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),

                // Balão de Mensagem
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: message.isMe ? primaryColor : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: message.isMe
                          ? const Radius.circular(20)
                          : const Radius.circular(4),
                      bottomRight: message.isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 15,
                      color:
                          message.isMe ? Colors.white : const Color(0xFF1E212B),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (message.isMe) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundImage: NetworkImage(message.avatarUrl),
    );
  }
}

class ChatInputArea extends StatelessWidget {
  final Color primaryColor;

  const ChatInputArea({super.key, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Respostas Rápidas (Chips)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildQuickReply('Estou no local'),
                  _buildQuickReply('Onde você está?'),
                  _buildQuickReply('Trânsito intenso'),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Campo de Texto e Botão de Enviar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFF3F4F6), // Cinza bem claro do input
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Envie uma mensagem...',
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: () {}, // Ação de enviar
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReply(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08), // Fundo rosa clarinho
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}
