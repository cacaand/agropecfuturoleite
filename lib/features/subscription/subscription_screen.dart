import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/security.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedPlan = 1; // 0=mensal, 1=anual, 2=quinquenal

  final plans = [
    _Plan(id: 0, name: 'Mensal',         months: 1,  priceMonth: 249.90, badge: '',             color: AppColors.blue600),
    _Plan(id: 1, name: 'Anual',          months: 12, priceMonth: 200.00, badge: 'Mais popular', color: AppColors.green700),
    _Plan(id: 2, name: '5 Anos',         months: 60, priceMonth: 180.00, badge: 'Melhor valor', color: AppColors.purple600),
  ];

  @override
  Widget build(BuildContext context) {
    final plan = plans[_selectedPlan];
    final total = plan.priceMonth * plan.months;
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: AppColors.gray700), onPressed: () => Navigator.pop(context)),
        title: const Text('Assinaturas', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.gray900)),
        bottom: const PreferredSize(preferredSize: Size.fromHeight(0.5), child: Divider(height: 0.5, color: AppColors.gray200)),
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        // Hero
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.green900, AppColors.green700], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('🐄 GadoLeite ERP Pro', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Gestão completa da sua fazenda', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _Feature('Animais ilimitados'),
              _Feature('Multi-fazenda'),
              _Feature('Relatórios PDF'),
              _Feature('Suporte prioritário'),
              _Feature('Backup automático'),
              _Feature('Atualizações grátis'),
            ]),
          ]),
        ),
        const SizedBox(height: 24),

        const Text('Escolha seu plano', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gray900)),
        const SizedBox(height: 12),

        // Plan cards
        ...plans.map((p) => _PlanCard(
          plan: p,
          selected: _selectedPlan == p.id,
          onTap: () => setState(() => _selectedPlan = p.id),
          currency: currency,
        )),
        const SizedBox(height: 24),

        // Total summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: plan.color.withOpacity(0.06), borderRadius: BorderRadius.circular(12),
            border: Border.all(color: plan.color.withOpacity(0.2))),
          child: Column(children: [
            Row(children: [
              Text('Plano ${plan.name}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray800)),
              const Spacer(),
              Text('${currency.format(plan.priceMonth)}/mês', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: plan.color)),
            ]),
            if (plan.months > 1) ...[
              const Divider(height: 16),
              Row(children: [
                const Text('Total cobrado', style: TextStyle(fontSize: 13, color: AppColors.gray600)),
                const Spacer(),
                Text(currency.format(total), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.gray900)),
              ]),
              if (_selectedPlan > 0) ...[
                const SizedBox(height: 4),
                Row(children: [
                  const Text('Economia vs mensal', style: TextStyle(fontSize: 12, color: AppColors.green700)),
                  const Spacer(),
                  Text(currency.format((249.90 * plan.months) - total),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.green700)),
                ]),
              ],
            ],
          ]),
        ),
        const SizedBox(height: 20),

        // Payment button
        ElevatedButton(
          onPressed: () => _showPayment(context, plan, total, currency),
          style: ElevatedButton.styleFrom(
            backgroundColor: plan.color,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Text('Assinar plano ${plan.name} →',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 12),
        const Center(child: Text('🔒 Pagamento 100% seguro · Cancele quando quiser',
          style: TextStyle(fontSize: 11, color: AppColors.gray400))),
        const SizedBox(height: 24),

        // FAQ
        _Faq('Posso cancelar a qualquer momento?', 'Sim. Você pode cancelar quando quiser. Para planos anuais e quinquenais, o acesso continua até o fim do período pago.'),
        _Faq('Meus dados ficam salvos?', 'Sim. Todos os seus dados ficam salvos localmente e em backup seguro na nuvem.'),
        _Faq('O plano cobre quantas fazendas?', 'Qualquer plano Pro cobre fazendas ilimitadas. No plano Trial, apenas 1 fazenda.'),
        _Faq('Como funciona o suporte?', 'Suporte via WhatsApp e email com resposta em até 4h para planos anuais e 2h para quinquenal.'),
      ]),
    );
  }

  void _showPayment(BuildContext context, _Plan plan, double total, NumberFormat currency) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => PaymentBottomSheet(plan: plan, total: total, currency: currency),
    );
  }
}

// ─── PAYMENT BOTTOM SHEET ─────────────────────────────────────────────────────

class PaymentBottomSheet extends StatefulWidget {
  final _Plan plan; final double total; final NumberFormat currency;
  const PaymentBottomSheet({super.key, required this.plan, required this.total, required this.currency});
  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _cardNum  = TextEditingController();
  final _cardName = TextEditingController();
  final _cardExp  = TextEditingController();
  final _cardCvv  = TextEditingController();
  final _cpf      = TextEditingController();
  bool _processing = false;
  bool _success    = false;

  // PIX key
  static const _pixKey = '00020126580014BR.GOV.BCB.PIX0136iamina-pagamentos@gadoleite.com.br5204000053039865802BR5923IAmina Software Ltda6009SAO PAULO62070503***6304';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _cardNum.dispose(); _cardName.dispose();
    _cardExp.dispose(); _cardCvv.dispose(); _cpf.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (_tab.index == 0) {
      // Card validation
      if (!AppSecurity.isValidCardNumber(_cardNum.text.replaceAll(' ', ''))) {
        _showError('Número de cartão inválido'); return;
      }
      if (_cardName.text.trim().length < 3) { _showError('Nome inválido'); return; }
      if (_cardExp.text.length < 5)          { _showError('Data inválida'); return; }
      if (_cardCvv.text.length < 3)          { _showError('CVV inválido'); return; }
    }

    setState(() => _processing = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulates API call
    if (mounted) setState(() { _processing = false; _success = true; });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.red600));
  }

  @override
  Widget build(BuildContext context) {
    if (_success) return _buildSuccess();
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.gray300, borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('Finalizar assinatura', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(widget.currency.format(widget.total),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: widget.plan.color)),
            ]),
            Text('Plano ${widget.plan.name} · ${widget.plan.months > 1 ? "${widget.plan.months} meses" : "mensal"}',
              style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
            const SizedBox(height: 16),
            TabBar(
              controller: _tab,
              labelColor: AppColors.green700, unselectedLabelColor: AppColors.gray500,
              indicatorColor: AppColors.green700,
              tabs: const [Tab(text: '💳  Cartão de Crédito'), Tab(text: 'PIX')],
            ),
            const SizedBox(height: 16),
            SizedBox(height: 320, child: TabBarView(controller: _tab, children: [
              _buildCardForm(),
              _buildPixForm(),
            ])),
            const SizedBox(height: 8),
            if (_processing)
              const Center(child: Column(children: [
                CircularProgressIndicator(color: AppColors.green700),
                SizedBox(height: 8),
                Text('Processando pagamento...', style: TextStyle(color: AppColors.gray500, fontSize: 13)),
              ]))
            else
              ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green700,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(_tab.index == 1 ? '✓ Confirmar pagamento PIX' : '🔒 Pagar com segurança',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            const SizedBox(height: 8),
            const Center(child: Text('🔐 Ambiente seguro · Dados criptografados · SSL 256 bits',
              style: TextStyle(fontSize: 10, color: AppColors.gray400))),
          ]),
        ),
      ]),
    );
  }

  Widget _buildCardForm() {
    return SingleChildScrollView(child: Column(children: [
      _CardField(_cardNum, 'Número do cartão', '0000 0000 0000 0000',
        type: TextInputType.number,
        format: [FilteringTextInputFormatter.digitsOnly, _CardNumberFormatter()]),
      const SizedBox(height: 10),
      _CardField(_cardName, 'Nome no cartão', 'JOÃO F SILVA', caps: TextCapitalization.characters),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _CardField(_cardExp, 'Validade', 'MM/AA',
          type: TextInputType.number,
          format: [FilteringTextInputFormatter.digitsOnly, _ExpiryFormatter()])),
        const SizedBox(width: 10),
        Expanded(child: _CardField(_cardCvv, 'CVV', '000',
          type: TextInputType.number, maxLen: 4,
          format: [FilteringTextInputFormatter.digitsOnly])),
      ]),
      const SizedBox(height: 10),
      _CardField(_cpf, 'CPF do titular', '000.000.000-00',
        type: TextInputType.number,
        format: [FilteringTextInputFormatter.digitsOnly, _CpfFormatter()]),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _CardBadge('visa'), const SizedBox(width: 8),
        _CardBadge('master'), const SizedBox(width: 8),
        _CardBadge('elo'), const SizedBox(width: 8),
        _CardBadge('amex'),
      ]),
    ]));
  }

  Widget _buildPixForm() {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.green700.withOpacity(0.3))),
        child: Column(children: [
          const Text('Chave PIX', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.green700)),
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: SelectableText('iamina-pagamentos@gadoleite.com.br',
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.gray800))),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: 'iamina-pagamentos@gadoleite.com.br'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chave PIX copiada!'), backgroundColor: AppColors.green700, duration: Duration(seconds: 2)));
              },
              icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.green700),
              label: const Text('Copiar chave', style: TextStyle(color: AppColors.green700, fontSize: 12)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.green700)),
            )),
          ]),
        ]),
      ),
      const SizedBox(height: 12),
      Container(padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.amber50, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.amber500.withOpacity(0.3))),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.info_outline_rounded, size: 16, color: AppColors.amber700),
            SizedBox(width: 6),
            Text('Como pagar via PIX:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.amber700)),
          ]),
          SizedBox(height: 6),
          Text('1. Abra o app do seu banco\n2. Escolha "Pix" → "Pagar"\n3. Cole a chave ou escaneie o QR Code\n4. Confirme o valor e seu plano é ativado automaticamente.',
            style: TextStyle(fontSize: 11, color: AppColors.amber700, height: 1.6)),
        ])),
      const SizedBox(height: 8),
      Text('Valor: ${widget.currency.format(widget.total)}',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.green700)),
    ]);
  }

  Widget _buildSuccess() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 80, height: 80,
          decoration: BoxDecoration(color: AppColors.green50, shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_rounded, color: AppColors.green700, size: 48)),
        const SizedBox(height: 20),
        const Text('Assinatura ativada! 🎉', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.gray900)),
        const SizedBox(height: 8),
        const Text('Seu plano foi ativado com sucesso.\nBoa gestão da sua fazenda!',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.gray500)),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () { Navigator.pop(context); Navigator.pop(context); },
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('Começar a usar →'),
        ),
      ]),
    );
  }
}

// ─── HELPER WIDGETS ──────────────────────────────────────────────────────────

class _Plan {
  final int id, months; final String name, badge; final double priceMonth; final Color color;
  const _Plan({required this.id, required this.name, required this.months, required this.priceMonth, required this.badge, required this.color});
}

class _PlanCard extends StatelessWidget {
  final _Plan plan; final bool selected; final VoidCallback onTap; final NumberFormat currency;
  const _PlanCard({required this.plan, required this.selected, required this.onTap, required this.currency});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected ? plan.color.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? plan.color : AppColors.gray200, width: selected ? 2 : 0.5)),
      child: Row(children: [
        Radio<int>(value: plan.id, groupValue: selected ? plan.id : -1,
          onChanged: (_) => onTap(), activeColor: plan.color),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(plan.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: selected ? plan.color : AppColors.gray900)),
            if (plan.badge.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: plan.color, borderRadius: BorderRadius.circular(20)),
                child: Text(plan.badge, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600))),
            ],
          ]),
          const SizedBox(height: 2),
          Text(plan.months == 1 ? 'Renovação mensal' : 'Cobrado ${plan.months == 12 ? "anualmente" : "a cada 5 anos"}',
            style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(currency.format(plan.priceMonth), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: plan.color)),
          const Text('/mês', style: TextStyle(fontSize: 11, color: AppColors.gray400)),
        ]),
      ]),
    ),
  );
}

Widget _Feature(String text) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
  child: Row(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.check_rounded, color: AppColors.green400, size: 12),
    const SizedBox(width: 4),
    Text(text, style: const TextStyle(color: Colors.white, fontSize: 11)),
  ]),
);

class _Faq extends StatefulWidget {
  final String q, a; const _Faq(this.q, this.a);
  @override State<_Faq> createState() => _FaqState();
}
class _FaqState extends State<_Faq> {
  bool _open = false;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.gray200, width: 0.5)),
    child: Column(children: [
      ListTile(onTap: () => setState(() => _open = !_open),
        title: Text(widget.q, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        trailing: Icon(_open ? Icons.expand_less : Icons.expand_more, color: AppColors.gray400)),
      if (_open) Padding(padding: const EdgeInsets.fromLTRB(16,0,16,12),
        child: Text(widget.a, style: const TextStyle(fontSize: 12, color: AppColors.gray600, height: 1.5))),
    ]),
  );
}

Widget _CardField(TextEditingController ctrl, String label, String hint, {
  TextInputType type = TextInputType.text,
  List<TextInputFormatter>? format, int? maxLen,
  TextCapitalization caps = TextCapitalization.none,
}) => TextField(controller: ctrl, keyboardType: type,
  inputFormatters: format, maxLength: maxLen,
  textCapitalization: caps,
  style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
  decoration: InputDecoration(labelText: label, hintText: hint, counterText: '',
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))));

Widget _CardBadge(String brand) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(6),
    border: Border.all(color: AppColors.gray200, width: 0.5)),
  child: Text(brand.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.gray500)));

// ─── INPUT FORMATTERS ─────────────────────────────────────────────────────────

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    final text = n.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length && i < 16; i++) {
      if (i % 4 == 0 && i != 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    final s = buffer.toString();
    return n.copyWith(text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    var text = n.text.replaceAll('/', '');
    if (text.length > 4) text = text.substring(0, 4);
    if (text.length >= 3) text = '${text.substring(0,2)}/${text.substring(2)}';
    return n.copyWith(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

class _CpfFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    var t = n.text.replaceAll(RegExp(r'\D'), '');
    if (t.length > 11) t = t.substring(0, 11);
    final b = StringBuffer();
    for (int i = 0; i < t.length; i++) {
      if (i == 3 || i == 6) b.write('.');
      if (i == 9) b.write('-');
      b.write(t[i]);
    }
    final s = b.toString();
    return n.copyWith(text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}
