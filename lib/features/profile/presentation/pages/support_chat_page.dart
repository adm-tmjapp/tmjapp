import 'package:flutter/material.dart';
import 'package:tmjapp/features/profile/presentation/services/support_contact_service.dart';

class SupportChatPage extends StatefulWidget {
  const SupportChatPage({super.key});
  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  final _controller = TextEditingController();
  final _contact = SupportContactService();
  final List<_Message> _messages = const [
    _Message(
        'Olá! Descreva sua dúvida. Posso orientar sobre corridas, pagamentos, cadastro e segurança.',
        false),
  ].toList();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(text, true));
      _messages.add(_Message(_answer(text), false));
    });
    _controller.clear();
  }

  String _answer(String message) {
    final value = message.toLowerCase();
    if (value.contains('pagamento') ||
        value.contains('pix') ||
        value.contains('cartão')) {
      return 'Confira a situação em Perfil > Pagamentos. Se houver cobrança indevida, encaminhe os detalhes por e-mail para análise da equipe.';
    }
    if (value.contains('corrida') || value.contains('motorista')) {
      return 'Abra o histórico de viagens para consultar a corrida. Em situações de risco durante uma viagem, use o botão SOS.';
    }
    if (value.contains('senha') ||
        value.contains('acesso') ||
        value.contains('conta')) {
      return 'Em Perfil > Segurança e Termos você pode alterar a senha e revisar o acesso biométrico.';
    }
    return 'Não encontrei uma orientação específica. Você pode encaminhar esta conversa por e-mail para a equipe de suporte.';
  }

  Future<void> _emailConversation() async {
    final transcript = _messages
        .map((m) => '${m.mine ? 'Cliente' : 'Assistente'}: ${m.text}')
        .join('\n\n');
    final opened = await _contact.emailSupport(
        subject: 'Atendimento iniciado no TMJApp', body: transcript);
    if (!mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Nenhum aplicativo de e-mail está disponível.')));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Chat de suporte'),
          actions: [
            IconButton(
                tooltip: 'Enviar por e-mail',
                onPressed: _emailConversation,
                icon: const Icon(Icons.email_outlined))
          ],
        ),
        body: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFFFF4FA),
            child: const Text(
                'Atendimento automático. Para falar com a equipe, envie a conversa por e-mail.',
                textAlign: TextAlign.center),
          ),
          Expanded(
              child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (_, index) {
              final message = _messages[index];
              return Align(
                alignment:
                    message.mine ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color:
                        message.mine ? const Color(0xFFC92D7A) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: message.mine
                        ? null
                        : Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(message.text,
                      style: TextStyle(
                          color: message.mine
                              ? Colors.white
                              : const Color(0xFF1D2939),
                          height: 1.35)),
                ),
              );
            },
          )),
          SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Expanded(
                      child: TextField(
                          controller: _controller,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: const InputDecoration(
                              hintText: 'Digite sua dúvida',
                              border: OutlineInputBorder()))),
                  const SizedBox(width: 8),
                  IconButton.filled(
                      onPressed: _send, icon: const Icon(Icons.send_rounded)),
                ]),
              )),
        ]),
      );
}

class _Message {
  const _Message(this.text, this.mine);
  final String text;
  final bool mine;
}
