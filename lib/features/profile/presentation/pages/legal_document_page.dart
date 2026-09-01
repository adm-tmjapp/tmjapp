import 'package:flutter/material.dart';

enum LegalDocument { terms, privacy }

class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({super.key, required this.document});
  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final terms = document == LegalDocument.terms;
    return Scaffold(
      appBar: AppBar(
          title: Text(terms ? 'Termos de uso' : 'Política de privacidade')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            terms
                ? 'Termos de uso do TMJApp'
                : 'Política de privacidade do TMJApp',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Última atualização: setembro de 2026',
              style: TextStyle(color: Color(0xFF667085))),
          const SizedBox(height: 24),
          ...(terms ? _termsSections : _privacySections).map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(section.$1,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(section.$2,
                      style: const TextStyle(
                          height: 1.55, color: Color(0xFF475467))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _termsSections = [
  (
    '1. Uso do serviço',
    'O TMJApp conecta passageiros a serviços de transporte. Ao usar o aplicativo, você concorda em fornecer informações verdadeiras e manter sua conta protegida.'
  ),
  (
    '2. Conta e segurança',
    'Você é responsável pelas atividades realizadas na sua conta e deve comunicar qualquer uso não autorizado. O acesso pode ser suspenso em caso de fraude, abuso ou violação destes termos.'
  ),
  (
    '3. Corridas e pagamentos',
    'Valores, formas de pagamento e condições da corrida são apresentados no aplicativo. Taxas de cancelamento podem ser aplicadas quando informadas antes da confirmação.'
  ),
  (
    '4. Conduta',
    'Não é permitido usar o serviço para fins ilegais, causar risco a terceiros, assediar usuários ou tentar comprometer o funcionamento da plataforma.'
  ),
  (
    '5. Disponibilidade',
    'O serviço pode sofrer interrupções por manutenção, conectividade, segurança ou eventos fora do controle razoável da plataforma.'
  ),
  (
    '6. Contato',
    'Dúvidas sobre estes termos podem ser encaminhadas pelo item Ajuda e suporte no Perfil.'
  ),
];

const _privacySections = [
  (
    '1. Dados coletados',
    'Podemos tratar dados de cadastro, contato, localização durante o uso, corridas, pagamentos, dispositivo e registros técnicos necessários à operação e segurança.'
  ),
  (
    '2. Finalidades',
    'Os dados são usados para autenticar sua conta, viabilizar corridas, processar pagamentos, oferecer suporte, prevenir fraudes e melhorar o serviço.'
  ),
  (
    '3. Compartilhamento',
    'Informações necessárias podem ser compartilhadas com motoristas, processadores de pagamento, provedores de infraestrutura e autoridades quando houver obrigação legal.'
  ),
  (
    '4. Armazenamento e segurança',
    'Aplicamos medidas técnicas e organizacionais para proteger os dados e os mantemos pelo período necessário às finalidades informadas e às obrigações legais.'
  ),
  (
    '5. Seus direitos',
    'Você pode solicitar acesso, correção, portabilidade, informação sobre compartilhamento e exclusão, observadas as hipóteses legais de retenção.'
  ),
  (
    '6. Contato',
    'Solicitações de privacidade podem ser enviadas pelo item Ajuda e suporte no Perfil.'
  ),
];
